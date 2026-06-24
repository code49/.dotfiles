#!/usr/bin/env python3
import json
import subprocess
import time
import os

def log(msg):
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    log_line = f"[{timestamp}] {msg}\n"
    print(log_line, end="")
    try:
        with open("/tmp/startup_apps.log", "a") as f:
            f.write(log_line)
    except Exception:
        pass

def run_cmd(cmd):
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return result.stdout.strip()

def get_clients():
    try:
        return json.loads(run_cmd(["hyprctl", "clients", "-j"]))
    except Exception as e:
        log(f"Error getting clients: {e}")
        return []

def get_active_workspace():
    try:
        data = json.loads(run_cmd(["hyprctl", "activeworkspace", "-j"]))
        return data.get("id", 1)
    except Exception:
        return 1

def resize_multiple_windows(resize_targets):
    if not resize_targets:
        return
    orig_ws = get_active_workspace()
    log(f"Performing resizes for: {resize_targets}. Current active workspace: {orig_ws}")
    
    # Group by workspace to minimize switching
    by_ws = {}
    for addr, ws, width_val in resize_targets:
        by_ws.setdefault(ws, []).append((addr, width_val))
        
    for ws, items in by_ws.items():
        log(f"Switching to workspace {ws} for resizing...")
        run_cmd(["hyprctl", "dispatch", "workspace", str(ws)])
        for addr, width_val in items:
            log(f"Focusing window {addr} and resizing column to {width_val}...")
            run_cmd(["hyprctl", "dispatch", "focuswindow", f"address:{addr}"])
            time.sleep(0.15)
            run_cmd(["hyprctl", "dispatch", "layoutmsg", f"colresize {width_val}"])
            time.sleep(0.15)
            
    log(f"Switching back to original workspace {orig_ws}...")
    run_cmd(["hyprctl", "dispatch", "workspace", str(orig_ws)])

def main():
    if os.path.exists("/tmp/startup_apps.log"):
        try:
            os.remove("/tmp/startup_apps.log")
        except Exception:
            pass

    log("Starting startup_apps.py script...")

    # 1. Start Firefox main process with landing page on Workspace 1
    log("Launching landing page on Workspace 1...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://davidlechan.dev"])
    time.sleep(3.0)

    # 2. Workspace 10 apps (launching in the desired left-to-right order: Instagram -> Direct -> WhatsApp -> Messages)
    log("Launching Workspace 10 apps...")
    log("Launching Instagram...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://www.instagram.com"])
    time.sleep(1.2)

    log("Launching Instagram Direct...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://www.instagram.com/direct/inbox"])
    time.sleep(1.2)

    log("Launching WhatsApp...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://web.whatsapp.com/"])
    time.sleep(1.2)

    log("Launching Google Messages...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://messages.google.com/web/conversations"])
    time.sleep(1.2)

    # 3. Workspace 9 apps (left-to-right: Calendar -> Notion -> Spotify)
    log("Launching Workspace 9 apps...")
    log("Launching Google Calendar...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://calendar.google.com/calendar/u/0/r"])
    time.sleep(1.2)

    log("Launching Notion...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://www.notion.so/davidlechan/d03cd6231ead496e808bdf0fe03f8566"])
    time.sleep(1.2)

    log("Launching Spotify...")
    subprocess.Popen(["spotify"])
    time.sleep(1.2)

    # Lambda-based target definitions for precise matching
    targets = [
        {
            "id": "instagram_main",
            "match": lambda c: c.get("class") == "firefox" and "instagram" in c.get("title", "").lower() and "messages" not in c.get("title", "").lower(),
            "workspace": 10,
            "resize": 0.5
        },
        {
            "id": "instagram_direct",
            "match": lambda c: c.get("class") == "firefox" and "instagram" in c.get("title", "").lower() and "messages" in c.get("title", "").lower(),
            "workspace": 10,
            "resize": 0.5
        },
        {
            "id": "whatsapp",
            "match": lambda c: c.get("class") == "firefox" and "whatsapp" in c.get("title", "").lower(),
            "workspace": 10
        },
        {
            "id": "messages",
            "match": lambda c: c.get("class") == "firefox" and "messages" in c.get("title", "").lower() and "instagram" not in c.get("title", "").lower(),
            "workspace": 10
        },
        {
            "id": "calendar",
            "match": lambda c: c.get("class") == "firefox" and "calendar" in c.get("title", "").lower(),
            "workspace": 9
        },
        {
            "id": "notion",
            "match": lambda c: c.get("class") == "firefox" and "notion" in c.get("title", "").lower(),
            "workspace": 9
        },
        {
            "id": "spotify",
            "match": lambda c: c.get("class", "").lower() == "spotify" or c.get("initialClass", "").lower() == "spotify",
            "workspace": 9
        }
    ]

    placed_targets = set()
    resized_targets = set()

    # Poll for up to 120 seconds (240 iterations * 0.5s)
    log("Starting polling loop for window placement...")
    for step in range(240):
        clients = get_clients()
        pending_resizes = []

        for target in targets:
            tid = target["id"]
            if tid in placed_targets and (target.get("resize") is None or tid in resized_targets):
                continue

            # Find matching client
            c = next((client for client in clients if target["match"](client)), None)
            if c:
                addr = c["address"]
                ws = target["workspace"]
                current_ws = c.get("workspace", {}).get("id")

                # Move if not on target workspace
                if current_ws != ws:
                    log(f"Found {tid} window ('{c.get('title')}'). Moving silent from workspace {current_ws} to {ws}...")
                    run_cmd(["hyprctl", "dispatch", "movetoworkspacesilent", f"{ws},address:{addr}"])
                
                placed_targets.add(tid)

                # Queue resize if target requires it
                if "resize" in target and tid not in resized_targets:
                    pending_resizes.append((addr, ws, target["resize"]))
                    resized_targets.add(tid)

        if pending_resizes:
            resize_multiple_windows(pending_resizes)

        # Check exit condition
        if len(placed_targets) == len(targets):
            log(f"All {len(targets)} targets successfully placed and resized! Exiting loop early at step {step}.")
            break

        time.sleep(0.5)
    else:
        missing = [t["id"] for t in targets if t["id"] not in placed_targets]
        log(f"Polling loop finished. Missing targets: {missing}")

if __name__ == "__main__":
    main()
