#!/usr/bin/env python3
import datetime
import json
import re
import urllib.request

def get_weather():
    # 1. Parse active timezone, city, and optional code comment from local.nix
    city = ""
    timezone = ""
    code = ""
    try:
        with open('/home/dchan/.dotfiles/local.nix', 'r') as f:
            content = f.read()
        match = re.search(r'^\s*(?!#|//)time\.timeZone\s*=\s*"([^"]+)"\s*;?(?:[ \t]*(?:#|//)[ \t]*([^\n]+))?', content, re.MULTILINE)
        if match:
            timezone = match.group(1)
            city = timezone.split('/')[-1] if '/' in timezone else timezone
            city = city.replace('_', ' ')
            code = match.group(2).strip() if match.group(2) else ""
            # Remove any trailing semicolon or comments formatting from the code
            code = code.rstrip(';')
    except Exception:
        pass

    if not city:
        city = "Chicago" # fallback default

    # Location to query: use code if provided (e.g. San Francisco, LAX), otherwise city
    query_location = code if code else city

    # 2. Fetch data from wttr.in
    try:
        url = f"https://wttr.in/{query_location.replace(' ', '+')}?format=j1"
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode())
            
        current = data['current_condition'][0]
        
        # Force Celsius for temperature
        temp = current['temp_C']
        feels = current['FeelsLikeC']
        unit = 'c'
        
        desc = current['weatherDesc'][0]['value'].lower()
        humidity = current['humidity']
        
        # Use metric wind speed (km/h) for consistency with Celsius
        wind = current['windspeedKmph']
        wind_unit = 'km/h'
        
        # Weather icons mapping
        weather_icons = {
            "sunny": "󰖙",
            "clear": "󰖙",
            "partly cloudy": "󰖕",
            "cloudy": "󰖐",
            "overcast": "󰖐",
            "mist": "󰖑",
            "fog": "󰖑",
            "haze": "󰖑",
            "rain": "󰖗",
            "light rain": "󰖗",
            "patchy rain": "󰖗",
            "heavy rain": "󰖖",
            "thunderstorm": "󰙾",
            "snow": "󰼶",
            "sleet": "󰼶",
        }
        
        icon = "󰖙"
        for key, val in weather_icons.items():
            if key in desc:
                icon = val
                break
                
        text = f"{icon}  {temp}"
        
        # Tooltip title: show either city/code or code (city)
        display_name = f"{code.lower()} ({city.lower()})" if code and code.lower() != city.lower() else city.lower()
        
        tooltip_lines = [
            f"{display_name} weather:",
            f"{desc}, {temp}°{unit} (feels like {feels}°{unit})",
            f"humidity: {humidity}%",
            f"wind: {wind} {wind_unit}"
        ]
        
        # Forecast
        if 'weather' in data:
            tooltip_lines.append("\nforecast:")
            days = ["today", "tomorrow", "day after"]
            for i, day_data in enumerate(data['weather'][:3]):
                day_name = days[i] if i < len(days) else day_data['date']
                max_t = day_data['maxtempC']
                min_t = day_data['mintempC']
                tooltip_lines.append(f"  {day_name}: {min_t}°{unit} - {max_t}°{unit}")
                
        tooltip = "\n".join(tooltip_lines)
        
    except Exception as e:
        text = "󰖙  --"
        tooltip = f"offline: {str(e).lower()}"
        
    return json.dumps({"text": text, "tooltip": tooltip})

if __name__ == '__main__':
    print(get_weather())
