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
    time.sleep(0.2)

    log("Launching Instagram Direct...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://www.instagram.com/direct/inbox"])
    time.sleep(0.2)

    log("Launching WhatsApp...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://web.whatsapp.com/"])
    time.sleep(0.2)

    log("Launching Google Messages...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://messages.google.com/web/conversations"])
    time.sleep(0.2)

    # 3. Workspace 9 apps (left-to-right: Calendar -> Notion -> Spotify)
    log("Launching Workspace 9 apps...")
    log("Launching Google Calendar...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://calendar.google.com/calendar/u/0/r/customday"])
    time.sleep(0.2)

    log("Launching Notion...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://www.notion.so/davidlechan/d03cd6231ead496e808bdf0fe03f8566"])
    time.sleep(0.2)

    log("Launching Spotify...")
    subprocess.Popen(["spotify"])
    time.sleep(0.2)

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
            "workspace": 9,
            "resize": 0.4
        },
        {
            "id": "notion",
            "match": lambda c: c.get("class") == "firefox" and "notion" in c.get("title", "").lower(),
            "workspace": 9,
            "resize": 0.6
        },
        {
            "id": "spotify",
            "match": lambda c: c.get("class", "").lower() == "spotify" or c.get("initialClass", "").lower() == "spotify",
            "workspace": 9
        }
    ]

    ws10_ids = ["instagram_main", "instagram_direct", "whatsapp", "messages"]
    ws9_ids = ["calendar", "notion", "spotify"]

    ws10_moved = False
    ws9_moved = False

    # Poll for up to 120 seconds (240 iterations * 0.5s)
    log("Starting polling loop for window placement...")
    for step in range(240):
        clients = get_clients()

        # 1. Check Workspace 10
        if not ws10_moved:
            found = {}
            for target in targets:
                if target["workspace"] == 10:
                    c = next((client for client in clients if target["match"](client)), None)
                    if c:
                        found[target["id"]] = c

            # If all 4 Workspace 10 targets are found, or if we have timed out (e.g. after step 100/50 seconds)
            # we move whatever we have found to guarantee they get moved.
            if len(found) == 4 or (step >= 100 and found):
                pending_resizes = []
                for tid in ws10_ids:
                    if tid in found:
                        c = found[tid]
                        addr = c["address"]
                        current_ws = c.get("workspace", {}).get("id")
                        if current_ws != 10:
                            log(f"Found Workspace 10 target '{tid}'. Moving silent to Workspace 10...")
                            run_cmd(["hyprctl", "dispatch", "movetoworkspacesilent", f"10,address:{addr}"])
                        
                        target_obj = next(t for t in targets if t["id"] == tid)
                        if "resize" in target_obj:
                            pending_resizes.append((addr, 10, target_obj["resize"]))

                if pending_resizes:
                    time.sleep(0.2)
                    resize_multiple_windows(pending_resizes)

                if len(found) == 4 or step >= 100:
                    ws10_moved = True
                    log(f"Workspace 10 windows successfully moved. Total found: {len(found)}")

        # 2. Check Workspace 9
        if not ws9_moved:
            found = {}
            for target in targets:
                if target["workspace"] == 9:
                    c = next((client for client in clients if target["match"](client)), None)
                    if c:
                        found[target["id"]] = c

            if len(found) == 3 or (step >= 100 and found):
                pending_resizes = []
                for tid in ws9_ids:
                    if tid in found:
                        c = found[tid]
                        addr = c["address"]
                        current_ws = c.get("workspace", {}).get("id")
                        if current_ws != 9:
                            log(f"Found Workspace 9 target '{tid}'. Moving silent to Workspace 9...")
                            run_cmd(["hyprctl", "dispatch", "movetoworkspacesilent", f"9,address:{addr}"])
                        
                        target_obj = next(t for t in targets if t["id"] == tid)
                        if "resize" in target_obj:
                            pending_resizes.append((addr, 9, target_obj["resize"]))

                if pending_resizes:
                    time.sleep(0.2)
                    resize_multiple_windows(pending_resizes)

                if len(found) == 3 or step >= 100:
                    ws9_moved = True
                    log(f"Workspace 9 windows successfully moved. Total found: {len(found)}")

        # Exit loop if both are moved
        if ws10_moved and ws9_moved:
            log("All workspace targets successfully placed and resized! Exiting loop early.")
            break

        time.sleep(0.5)
    else:
        log("Polling loop timed out.")

    # Close the landing page splash screen at the end
    log("Attempting to close the landing page window...")
    for _ in range(10): # Try for up to 5 seconds
        clients = get_clients()
        landing_window = next((c for c in clients if c.get("class") == "firefox" and "david le chan" in c.get("title", "").lower()), None)
        if landing_window:
            addr = landing_window["address"]
            log(f"Closing startup landing page window ({addr})...")
            run_cmd(["hyprctl", "dispatch", "closewindow", f"address:{addr}"])
            break
        time.sleep(0.5)
    else:
        log("Landing page window not found or title did not load.")

if __name__ == "__main__":
    main()
