#!/usr/bin/env python3
import datetime
import json
import subprocess
import re
from zoneinfo import ZoneInfo

def get_visible_len(s):
    # Strip HTML/Pango tags to get visible character length
    return len(re.sub(r'<[^>]*>', '', s))

def get_lowercase_clock():
    now = datetime.datetime.now()
    text = now.strftime('%A | %d.%m.%y | %H:%M:%S').lower()
    
    # Get calendar
    try:
        cal = subprocess.check_output(['cal'], text=True).lower().rstrip()
        # Highlight today's date in the calendar
        day = now.day
        # Match the day as a separate word to avoid partial matches
        pattern = rf'\b{day}\b'
        highlighted = f"<span color='#d7bee9'><b><u>{day}</u></b></span>"
        cal_highlighted = re.sub(pattern, highlighted, cal, count=1)
    except Exception:
        cal_highlighted = text

    # Fetch world clocks
    world_zones = [
        ("taipei", "Asia/Taipei"),
        ("pittsburgh", "America/New_York"),
        ("san francisco", "America/Los_Angeles")
    ]
    
    clock_lines = []
    for city, zone in world_zones:
        try:
            tz_now = datetime.datetime.now(ZoneInfo(zone))
            time_str = tz_now.strftime('%H:%M:%S').lower()
            diff = (tz_now.date() - now.date()).days
            diff_str = f" (+{diff})" if diff > 0 else (f" ({diff})" if diff < 0 else "")
            clock_lines.append(f"{city:<15} {time_str}{diff_str}")
        except Exception as e:
            clock_lines.append(f"{city:<15} error: {str(e).lower()}")
            
    # Centering Calendar Block
    cal_lines = cal_highlighted.split('\n')
    if cal_lines:
        cal_lines[0] = f"<b>{cal_lines[0]}</b>"
        
    cal_width = max(get_visible_len(line) for line in cal_lines)
    all_lines = cal_lines + clock_lines
    max_len = max(get_visible_len(line) for line in all_lines)
    
    left_pad = (max_len - cal_width) // 2
    centered_cal_lines = [(" " * left_pad) + line for line in cal_lines]
    centered_cal = "\n".join(centered_cal_lines)
    
    world_clocks = "\n" + "\n".join(clock_lines)
    
    # Combine calendar and world clocks, wrapping the whole tooltip in <tt>
    # to ensure monospace font for calendar alignment.
    tooltip = f"<tt>{centered_cal}\n{world_clocks}</tt>"
        
    return json.dumps({"text": text, "tooltip": tooltip})

if __name__ == '__main__':
    print(get_lowercase_clock())
