#!/usr/bin/env python3
import datetime
import json
import re
import urllib.request
import urllib.error


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
        
        temp_c = current['temp_C']
        feels_c = current['FeelsLikeC']
        temp_f = current['temp_F']
        feels_f = current['FeelsLikeF']
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
                
        text = f"{icon}  {temp_c}"
        
        # Tooltip title: show either city/code or code (city)
        display_name = f"{code.lower()} ({city.lower()})" if code and code.lower() != city.lower() else city.lower()
        
        def fmt(val):
            try:
                v = int(val)
                return f"{v:02d}"
            except Exception:
                return str(val)

        tooltip_lines = [
            f"{display_name} weather:",
            f"  {'condition:':<12} {desc.strip()}",
            f"  {'temperature:':<12} {fmt(temp_c)}°{unit} / {fmt(temp_f)}°f (feels like {fmt(feels_c)}°{unit} / {fmt(feels_f)}°f)",
            f"  {'humidity:':<12} {fmt(humidity)}%",
            f"  {'wind:':<12} {fmt(wind)} {wind_unit}"
        ]
        
        # Forecast
        if 'weather' in data:
            tooltip_lines.append("\nforecast:")
            days = ["today", "tomorrow", "day after"]
            for i, day_data in enumerate(data['weather'][:3]):
                day_name = days[i] if i < len(days) else day_data['date']
                max_c = day_data['maxtempC']
                min_c = day_data['mintempC']
                max_f = day_data['maxtempF']
                min_f = day_data['mintempF']
                day_label = f"{day_name}:"
                tooltip_lines.append(f"  {day_label:<10} {fmt(min_c)}°{unit} / {fmt(min_f)}°f - {fmt(max_c)}°{unit} / {fmt(max_f)}°f")
                
        tooltip = "\n".join(tooltip_lines)
        
    except urllib.error.HTTPError as e:
        text = "󰖙  --"
        if e.code == 429:
            tooltip = "offline: wttr.in rate limit exceeded (too many requests)"
        elif e.code in (502, 503, 504):
            tooltip = "offline: wttr.in server is overloaded or down"
        elif e.code == 404:
            tooltip = f"offline: location '{query_location}' not found"
        else:
            tooltip = f"offline: HTTP error {e.code} ({e.reason.lower() if e.reason else 'unknown'})"
    except urllib.error.URLError as e:
        text = "󰖙  --"
        reason_str = str(e.reason).lower()
        if "temporary failure in name resolution" in reason_str or "name or service not known" in reason_str:
            tooltip = "offline: network offline or DNS resolution failed"
        elif "timed out" in reason_str:
            tooltip = "offline: connection to wttr.in timed out"
        else:
            tooltip = f"offline: network error ({reason_str})"
    except json.JSONDecodeError:
        text = "󰖙  --"
        tooltip = "offline: received invalid response from wttr.in (server may be down or returning html)"
    except (KeyError, IndexError, ValueError) as e:
        text = "󰖙  --"
        tooltip = f"offline: failed to parse weather data ({str(e).lower()})"
    except Exception as e:
        text = "󰖙  --"
        tooltip = f"offline: unexpected error ({str(e).lower()})"
        
    return json.dumps({"text": text, "tooltip": tooltip})

if __name__ == '__main__':
    print(get_weather())
