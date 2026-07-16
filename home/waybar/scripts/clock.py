#!/usr/bin/env python3
import datetime
import json
import subprocess
import re

def get_lowercase_clock():
    now = datetime.datetime.now()
    text = now.strftime('%A | %d.%m.%y | %H:%M:%S').lower()
    
    # Get calendar
    try:
        cal = subprocess.check_output(['cal'], text=True).lower()
        # Highlight today's date in the calendar
        day = now.day
        # Match the day as a separate word to avoid partial matches
        pattern = rf'\b{day}\b'
        highlighted = f"<span color='#d7bee9'><b><u>{day}</u></b></span>"
        cal_highlighted = re.sub(pattern, highlighted, cal, count=1)
        # Wrap in monospaced tags
        tooltip = f"<tt><small>{cal_highlighted}</small></tt>"
    except Exception:
        tooltip = text
        
    return json.dumps({"text": text, "tooltip": tooltip})

if __name__ == '__main__':
    print(get_lowercase_clock())
