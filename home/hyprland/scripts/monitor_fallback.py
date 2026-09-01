#!/usr/bin/env python3
import json
import os
import socket
import subprocess
import sys
import time

MONITORS_CONF = os.path.expanduser("~/.config/hypr/monitors.conf")

def get_connected_monitors():
    """Returns a list of connected monitor names (e.g. ['eDP-1', 'DP-1'])"""
    try:
        res = subprocess.run(["hyprctl", "monitors", "-j"], capture_output=True, text=True)
        if res.returncode == 0:
            monitors = json.loads(res.stdout)
            return [m["name"] for m in monitors if not m.get("disabled", False)]
    except Exception as e:
        print(f"[monitor_fallback] Error fetching monitors: {e}", file=sys.stderr)
    return []

def validate_and_fallback():
    """
    Checks ~/.config/hypr/monitors.conf against currently connected monitors.
    If monitors.conf contains lines referencing disconnected monitors,
    or if eDP-1 is left offset without a monitor at (0,0), it cleans monitors.conf
    and re-applies valid monitor layout.
    """
    if not os.path.exists(MONITORS_CONF):
        return

    connected = get_connected_monitors()
    if not connected:
        return

    try:
        with open(MONITORS_CONF, "r") as f:
            lines = f.readlines()
    except Exception as e:
        print(f"[monitor_fallback] Error reading {MONITORS_CONF}: {e}", file=sys.stderr)
        return

    modified = False
    new_lines = []
    
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("monitor="):
            parts = stripped[len("monitor="):].split(",")
            mon_name = parts[0].strip()
            
            # Remove rule if specified monitor is not physically connected
            if mon_name and mon_name != "" and mon_name not in connected:
                print(f"[monitor_fallback] Removing stale monitor rule for disconnected display: {mon_name}")
                modified = True
                continue

            # If eDP-1 is the only connected display, ensure it starts at 0x0
            if len(connected) == 1 and connected[0] == "eDP-1" and mon_name == "eDP-1":
                if len(parts) >= 3:
                    pos = parts[2].strip()
                    if pos != "0x0" and pos != "auto":
                        print(f"[monitor_fallback] Resetting eDP-1 position from {pos} to 0x0 since it is sole display.")
                        scale = parts[3].strip() if len(parts) >= 4 else "1.67"
                        line = f"monitor=eDP-1,2880x1920@60.0,0x0,{scale}\n"
                        modified = True

        new_lines.append(line)

    if modified:
        try:
            with open(MONITORS_CONF, "w") as f:
                f.writelines(new_lines)
            print(f"[monitor_fallback] Cleaned {MONITORS_CONF}. Reloading Hyprland...")
            subprocess.run(["hyprctl", "reload"], check=False)
        except Exception as e:
            print(f"[monitor_fallback] Error saving {MONITORS_CONF}: {e}", file=sys.stderr)

def listen_ipc():
    """Listens on Hyprland socket2 for monitoradded and monitorremoved events."""
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    xdg_runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    if not sig:
        # Fallback to finding signature dir if env var not inherited
        hypr_dir = os.path.join(xdg_runtime, "hypr")
        if os.path.exists(hypr_dir):
            dirs = [d for d in os.listdir(hypr_dir) if os.path.isdir(os.path.join(hypr_dir, d))]
            if dirs:
                sig = dirs[0]

    if not sig:
        print("[monitor_fallback] HYPRLAND_INSTANCE_SIGNATURE not found", file=sys.stderr)
        return

    sock_path = os.path.join(xdg_runtime, "hypr", sig, ".socket2.sock")
    if not os.path.exists(sock_path):
        print(f"[monitor_fallback] Socket path {sock_path} does not exist.", file=sys.stderr)
        return

    print(f"[monitor_fallback] Daemon listening on {sock_path}...")
    while True:
        try:
            s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            s.connect(sock_path)
            with s.makefile("r") as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("monitoradded>>") or line.startswith("monitorremoved>>"):
                        print(f"[monitor_fallback] Event received: {line}")
                        time.sleep(0.5) # allow driver to settle
                        validate_and_fallback()
        except Exception as e:
            print(f"[monitor_fallback] Socket error: {e}. Reconnecting in 3s...", file=sys.stderr)
            time.sleep(3)

def main():
    if "--daemon" in sys.argv:
        validate_and_fallback()
        listen_ipc()
    else:
        validate_and_fallback()

if __name__ == "__main__":
    main()
