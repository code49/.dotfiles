#!/usr/bin/env python3
import json
import subprocess
import time
import os
import socket

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

IS_LUA = None

def is_lua_mode():
    global IS_LUA
    if IS_LUA is not None:
        return IS_LUA
    res = subprocess.run(["hyprctl", "dispatch", "hl.dsp.no_op()"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    IS_LUA = (res.returncode == 0)
    return IS_LUA

def dispatch_cmd(lua_expr, legacy_args):
    """Execute a hyprctl dispatch command supporting both Lua and legacy syntax."""
    if is_lua_mode():
        cmd = ["hyprctl", "dispatch", lua_expr]
    else:
        cmd = ["hyprctl", "dispatch"] + legacy_args
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if res.returncode != 0:
        err_msg = res.stderr.strip() or res.stdout.strip()
        log(f"Dispatch error ({res.returncode}) running {cmd}: {err_msg}")
    return res.stdout.strip()

def launch_detached(cmd):
    """Launch process detached via double fork so bwrap --die-with-parent survives script exit."""
    pid = os.fork()
    if pid == 0:
        os.setsid()
        pid2 = os.fork()
        if pid2 == 0:
            devnull = os.open(os.devnull, os.O_RDWR)
            os.dup2(devnull, 0)
            os.dup2(devnull, 1)
            os.dup2(devnull, 2)
            os.close(devnull)
            os.execvp(cmd[0], cmd)
        else:
            os._exit(0)
    os.waitpid(pid, 0)

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

def get_monitors():
    try:
        return json.loads(run_cmd(["hyprctl", "monitors", "-j"]))
    except Exception as e:
        log(f"Error getting monitors: {e}")
        return []

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
        dispatch_cmd(f'hl.dsp.focus({{ workspace = "{ws}" }})', ["workspace", str(ws)])
        for addr, width_val in items:
            log(f"Focusing window {addr} and resizing column to {width_val}...")
            dispatch_cmd(f'hl.dsp.focus({{ window = "address:{addr}" }})', ["focuswindow", f"address:{addr}"])
            time.sleep(0.15)
            dispatch_cmd(f'hl.dsp.layout("colresize {width_val}")', ["layoutmsg", f"colresize {width_val}"])
            time.sleep(0.15)
            
    log(f"Switching back to original workspace {orig_ws}...")
    dispatch_cmd(f'hl.dsp.focus({{ workspace = "{orig_ws}" }})', ["workspace", str(orig_ws)])

def check_internet():
    for host in ["1.1.1.1", "8.8.8.8"]:
        try:
            socket.create_connection((host, 53), timeout=2.0)
            return True
        except OSError:
            pass
    return False

def main():
    if os.path.exists("/tmp/startup_apps.log"):
        try:
            os.remove("/tmp/startup_apps.log")
        except Exception:
            pass

    log("Starting startup_apps.py script...")

    # Check internet connectivity before opening external sites
    if not check_internet():
        log("Auto-start failed: No internet connection.")
        try:
            subprocess.run(["notify-send", "-i", "firefox", "Firefox Shortcuts", "Auto-start failed: No internet connection."])
        except Exception as e:
            log(f"Failed to send notification: {e}")
        return

    # Determine the primary monitor (prefer external monitor over eDP-1, prioritizing DP-2 if connected)
    monitors = get_monitors()
    external = [m["name"] for m in monitors if m.get("name") != "eDP-1"]
    if "DP-2" in external:
        primary_monitor = "DP-2"
    else:
        primary_monitor = external[0] if external else "eDP-1"
    log(f"Primary monitor identified as: {primary_monitor}")

    # Focus the primary monitor and workspace 1 before launching apps
    log(f"Focusing monitor {primary_monitor} and workspace 1...")
    dispatch_cmd(f'hl.dsp.focus({{ monitor = "{primary_monitor}" }})', ["focusmonitor", primary_monitor])
    dispatch_cmd(f'hl.dsp.focus({{ workspace = "1" }})', ["workspace", "1"])
    dispatch_cmd(f'hl.dsp.workspace.move({{ workspace = "1", monitor = "{primary_monitor}" }})', ["moveworkspacetomonitor", f"1 {primary_monitor}"])

    # 1. Start Firefox main process with landing page on Workspace 1
    log("Launching landing page on Workspace 1...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://davidlechan.dev"])
    time.sleep(3.0)

    # 2. Workspace 10 apps (launching in the desired left-to-right order: Direct -> WhatsApp -> Messages -> Discord)
    log("Launching Workspace 10 apps...")
    log("Launching Instagram Direct...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://www.instagram.com/direct/inbox"])
    time.sleep(0.2)

    log("Launching WhatsApp...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://web.whatsapp.com/"])
    time.sleep(0.2)

    log("Launching Google Messages...")
    subprocess.Popen(["firefox", "-p", "dchan-personal", "-new-window", "https://messages.google.com/web/conversations"])
    time.sleep(0.2)

    log("Launching Discord...")
    launch_detached(["discord"])
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
    launch_detached(["spotify"])
    time.sleep(0.2)

    # Lambda-based target definitions for precise matching
    targets = [
        {
            "id": "instagram_direct",
            "match": lambda c: c.get("class") == "firefox" and "instagram" in c.get("title", "").lower(),
            "workspace": 10,
            "resize": 0.5
        },
        {
            "id": "whatsapp",
            "match": lambda c: c.get("class") == "firefox" and "whatsapp" in c.get("title", "").lower(),
            "workspace": 10,
            "resize": 0.5
        },
        {
            "id": "messages",
            "match": lambda c: c.get("class") == "firefox" and "messages" in c.get("title", "").lower() and "instagram" not in c.get("title", "").lower(),
            "workspace": 10,
            "resize": 0.5
        },
        {
            "id": "discord",
            "match": lambda c: (
                ("discord" in c.get("class", "").lower() or "discord" in c.get("initialClass", "").lower() or "discord" in c.get("title", "").lower())
                and "updater" not in c.get("title", "").lower()
                and "updater" not in c.get("initialTitle", "").lower()
            ),
            "workspace": 10,
            "resize": 0.5
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
            "match": lambda c: "spotify" in c.get("class", "").lower() or "spotify" in c.get("initialClass", "").lower() or "spotify" in c.get("title", "").lower(),
            "workspace": 9
        }
    ]

    ws_targets = {
        10: ["instagram_direct", "whatsapp", "messages", "discord"],
        9: ["calendar", "notion", "spotify"]
    }

    moved_targets = set()
    resized_workspaces = set()

    # Poll for up to 120 seconds (240 iterations * 0.5s)
    log("Starting polling loop for window placement...")
    for step in range(240):
        clients = get_clients()

        # 1. Detect and move target windows in strict left-to-right order per workspace
        for ws, t_ids in ws_targets.items():
            for tid in t_ids:
                if tid in moved_targets:
                    continue

                target_obj = next(t for t in targets if t["id"] == tid)
                c = next((client for client in clients if target_obj["match"](client)), None)

                if c:
                    addr = c["address"]
                    current_ws = c.get("workspace", {}).get("id")
                    if current_ws != ws:
                        log(f"Found target '{tid}' on workspace {current_ws}. Moving silent to workspace {ws}...")
                        dispatch_cmd(f'hl.dsp.window.move({{ workspace = "{ws}", follow = false, window = "address:{addr}" }})', ["movetoworkspacesilent", f"{ws},address:{addr}"])
                        time.sleep(0.1)
                        # Ensure workspace is located on primary monitor now that it exists
                        dispatch_cmd(f'hl.dsp.workspace.move({{ workspace = "{ws}", monitor = "{primary_monitor}" }})', ["moveworkspacetomonitor", f"{ws} {primary_monitor}"])
                    else:
                        log(f"Target '{tid}' already on workspace {ws}.")
                    moved_targets.add(tid)
                else:
                    # Target not ready yet. Pause processing subsequent targets for this workspace
                    # to maintain strict left-to-right window ordering, unless timed out.
                    if step < 60:  # 30 seconds grace period
                        break

        # 2. Check per workspace if all targets for that workspace are moved and pending resize
        for ws, t_ids in ws_targets.items():
            if ws not in resized_workspaces:
                if all(tid in moved_targets for tid in t_ids):
                    log(f"All targets for Workspace {ws} moved. Enforcing column order and applying resizes...")
                    
                    # Refresh clients
                    current_clients = get_clients()

                    # Re-dispatch in strict left-to-right sequence to guarantee column ordering
                    for tid in t_ids:
                        target_obj = next(t for t in targets if t["id"] == tid)
                        c = next((client for client in current_clients if target_obj["match"](client)), None)
                        if c:
                            c_addr = c["address"]
                            dispatch_cmd(f'hl.dsp.window.move({{ workspace = "{ws}", follow = false, window = "address:{c_addr}" }})', ["movetoworkspacesilent", f"{ws},address:{c_addr}"])
                            time.sleep(0.1)

                    pending_resizes = []
                    current_clients = get_clients()
                    for tid in t_ids:
                        target_obj = next(t for t in targets if t["id"] == tid)
                        if "resize" in target_obj:
                            c = next((client for client in current_clients if target_obj["match"](client)), None)
                            if c:
                                pending_resizes.append((c["address"], ws, target_obj["resize"]))

                    if pending_resizes:
                        time.sleep(0.2)
                        resize_multiple_windows(pending_resizes)

                    resized_workspaces.add(ws)
                    log(f"Workspace {ws} windows successfully ordered and resized.")

        # Exit loop early if all targets across all workspaces have been moved and resized
        all_target_ids = set(ws_targets[10] + ws_targets[9])
        if moved_targets >= all_target_ids and len(resized_workspaces) == len(ws_targets):
            log("All workspace targets successfully placed and resized! Exiting loop early.")
            break

        time.sleep(0.5)
    else:
        log("Polling loop timed out. Performing fallback order & resize for any moved targets...")
        current_clients = get_clients()
        for ws, t_ids in ws_targets.items():
            if ws not in resized_workspaces:
                pending_resizes = []
                for tid in t_ids:
                    if tid in moved_targets:
                        target_obj = next(t for t in targets if t["id"] == tid)
                        c = next((client for client in current_clients if target_obj["match"](client)), None)
                        if c:
                            c_addr = c["address"]
                            dispatch_cmd(f'hl.dsp.window.move({{ workspace = "{ws}", follow = false, window = "address:{c_addr}" }})', ["movetoworkspacesilent", f"{ws},address:{c_addr}"])
                            time.sleep(0.1)
                            if "resize" in target_obj:
                                pending_resizes.append((c["address"], ws, target_obj["resize"]))
                if pending_resizes:
                    resize_multiple_windows(pending_resizes)

    # Close the landing page splash screen at the end
    log("Attempting to close the landing page window...")
    for _ in range(10): # Try for up to 5 seconds
        clients = get_clients()
        landing_window = next((c for c in clients if c.get("class") == "firefox" and "david le chan" in c.get("title", "").lower()), None)
        if landing_window:
            addr = landing_window["address"]
            log(f"Closing startup landing page window ({addr})...")
            dispatch_cmd(f'hl.dsp.window.close({{ window = "address:{addr}" }})', ["closewindow", f"address:{addr}"])
            break
        time.sleep(0.5)
    else:
        log("Landing page window not found or title did not load.")

if __name__ == "__main__":
    main()
