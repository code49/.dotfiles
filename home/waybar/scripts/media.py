#!/usr/bin/env python3
import sys
import json
import re

def clean_track_name(name):
    """
    Cleans song titles by removing common extra text (such as "feat. ...",
    "with ...", "Remastered", "Radio Edit", "Live", etc.).
    """
    if not name:
        return name
    
    keywords = [
        r'feat\.?', r'ft\.?', r'featuring', r'with', r'remaster(ed)?', r'live', r'acoustic', 
        r'radio\s+edit', r'edit', r'bonus', r'single', r'deluxe', r'extended', 
        r'original\s+mix', r'mix', r'version', r'instrumental', r'edition', r'mono', r'stereo',
        r'from\s+.*?(?:series|tv\s+series|television\s+series|soundtrack|motion\s+picture|movie|anime|show|film|video\s+game)'
    ]
    
    keywords_pattern = '|'.join(keywords)
    paren_regex = re.compile(
        r'\s*[\(\[][^\]\)]*(?:' + keywords_pattern + r')[^\]\)]*[\)\]]',
        re.IGNORECASE
    )
    
    hyphen_regex = re.compile(
        r'\s*-\s*.*?(?:' + keywords_pattern + r').*',
        re.IGNORECASE
    )
    
    cleaned = name
    cleaned = hyphen_regex.sub('', cleaned)
    cleaned = paren_regex.sub('', cleaned)
    cleaned = cleaned.strip()
    return cleaned if cleaned else name

def main():
    for line in sys.stdin:
        parts = line.strip().split('\t')
        if len(parts) >= 4:
            title, artist, player, status = parts[0], parts[1], parts[2], parts[3]
            title_cleaned = clean_track_name(title)
            
            # Formulate text and tooltip in lowercase
            text = f"{title_cleaned} - {artist}".lower()
            tooltip = player.lower()
            
            # Output in JSON format expected by Waybar
            out = {
                "text": text,
                "tooltip": tooltip,
                "alt": status,
                "class": status
            }
            print(json.dumps(out), flush=True)

if __name__ == '__main__':
    main()
