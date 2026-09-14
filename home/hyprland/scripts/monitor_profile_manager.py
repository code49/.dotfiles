#!/usr/bin/env python3
"""
Monitor Profile Manager for Hyprland
Automates monitor layout saving and restoration based on host + connected monitor hardware signatures.

Features:
- Hashes host + connected monitor EDIDs/specs to identify unique display setups.
- Saves nwg-displays layouts (~/.config/hypr/monitors.conf) to host-specific profile directories (~/.config/hypr/monitor_profiles/<hostname>/).
- Restores saved layouts automatically when connecting to known monitor setups.
- Runs as a daemon watching Hyprland socket2 (hotplug events) and ~/.config/hypr/monitors.conf (nwg-displays saves).
"""

import os
import sys
import json
import time
import socket
import shutil
import hashlib
import threading
import subprocess

MONITORS_CONF = os.path.expanduser("~/.config/hypr/monitors.conf")
HOSTNAME = socket.gethostname()
CONFIG_DIR = os.path.expanduser(f"~/.config/hypr/monitor_profiles/{HOSTNAME}")
DOTFILES_DIR = os.path.expanduser(f"~/.dotfiles/hosts/{HOSTNAME}/monitor_profiles")

def ensure_dirs():
    os.makedirs(CONFIG_DIR, exist_ok=True)
    if os.path.exists(os.path.expanduser(f"~/.dotfiles/hosts/{HOSTNAME}")):
        os.makedirs(DOTFILES_DIR, exist_ok=True)

def get_setup_signature():
    """Returns (hostname, sig_hash, monitor_list) representing current connected monitor setup."""
    try:
        res = subprocess.run(["hyprctl", "monitors", "all", "-j"], capture_output=True, text=True, timeout=5)
        if res.returncode != 0:
            return HOSTNAME, None, []
        monitors = json.loads(res.stdout)
    except Exception as e:
        print(f"[monitor_profile_manager] Error querying monitors: {e}", file=sys.stderr)
        return HOSTNAME, None, []

    connected_monitors = [m for m in monitors if not m.get("disabled", False)]
    if not connected_monitors:
        connected_monitors = monitors

    specs = []
    mon_info = []
    # Sort deterministically by hardware identity
    for m in sorted(connected_monitors, key=lambda x: (x.get("make", ""), x.get("model", ""), x.get("serial", ""), x.get("name", ""))):
        make = m.get("make", "").strip()
        model = m.get("model", "").strip()
        serial = m.get("serial", "").strip()
        desc = m.get("description", "").strip()
        name = m.get("name", "").strip()
        spec_str = f"{make}:{model}:{serial}:{desc}:{name}"
        specs.append(spec_str)
        mon_info.append({
            "name": name,
            "make": make,
            "model": model,
            "serial": serial,
            "description": desc,
            "width": m.get("width"),
            "height": m.get("height"),
            "refreshRate": m.get("refreshRate")
        })

    sig_str = f"{HOSTNAME}|" + "|".join(specs)
    sig_hash = hashlib.sha256(sig_str.encode()).hexdigest()[:12]
    return HOSTNAME, sig_hash, mon_info

def notify(title, message):
    try:
        subprocess.run(["notify-send", "-a", "MonitorProfileManager", title, message], check=False)
    except Exception:
        pass

def save_current_profile():
    """Saves the active ~/.config/hypr/monitors.conf to the profile corresponding to current monitor hash."""
    ensure_dirs()
    hostname, sig_hash, mon_info = get_setup_signature()
    if not sig_hash or not os.path.exists(MONITORS_CONF):
        return

    profile_conf = os.path.join(CONFIG_DIR, f"{sig_hash}.conf")
    profile_json = os.path.join(CONFIG_DIR, f"{sig_hash}.json")

    try:
        shutil.copy2(MONITORS_CONF, profile_conf)
        
        meta = {
            "hostname": hostname,
            "hash": sig_hash,
            "updated_at": time.strftime("%Y-%m-%d %H:%M:%S"),
            "monitors": mon_info
        }
        with open(profile_json, "w") as f:
            json.dump(meta, f, indent=2)

        # Sync to dotfiles host dir if available
        if os.path.exists(DOTFILES_DIR):
            shutil.copy2(profile_conf, os.path.join(DOTFILES_DIR, f"{sig_hash}.conf"))
            shutil.copy2(profile_json, os.path.join(DOTFILES_DIR, f"{sig_hash}.json"))

        print(f"[monitor_profile_manager] Saved layout for setup {sig_hash} ({len(mon_info)} displays)")
    except Exception as e:
        print(f"[monitor_profile_manager] Error saving profile: {e}", file=sys.stderr)

def auto_restore():
    """Checks if a saved profile exists for current setup. If so, restores it."""
    ensure_dirs()
    hostname, sig_hash, mon_info = get_setup_signature()
    if not sig_hash:
        return

    profile_conf = os.path.join(CONFIG_DIR, f"{sig_hash}.conf")

    if os.path.exists(profile_conf):
        try:
            with open(profile_conf, "r") as f:
                saved_content = f.read()

            current_content = ""
            if os.path.exists(MONITORS_CONF):
                with open(MONITORS_CONF, "r") as f:
                    current_content = f.read()

            if saved_content.strip() != current_content.strip():
                with open(MONITORS_CONF, "w") as f:
                    f.write(saved_content)
                print(f"[monitor_profile_manager] Restored layout for setup {sig_hash}")
                subprocess.run(["hyprctl", "reload"], check=False)
                notify("Monitor Layout Auto-Restored", f"Applied saved profile for {len(mon_info)} display(s) [{sig_hash}]")
        except Exception as e:
            print(f"[monitor_profile_manager] Error restoring profile: {e}", file=sys.stderr)
    else:
        # Profile doesn't exist yet, save current monitors.conf as initial profile
        print(f"[monitor_profile_manager] New monitor setup detected ({sig_hash}). Initializing profile.")
        save_current_profile()

def watch_monitors_conf(stop_event):
    """Watches ~/.config/hypr/monitors.conf for mtime changes and updates profile."""
    last_mtime = 0
    if os.path.exists(MONITORS_CONF):
        last_mtime = os.path.getmtime(MONITORS_CONF)

    while not stop_event.is_set():
        time.sleep(2)
        if os.path.exists(MONITORS_CONF):
            try:
                mtime = os.path.getmtime(MONITORS_CONF)
                if mtime > last_mtime + 0.5:
                    last_mtime = mtime
                    print("[monitor_profile_manager] monitors.conf modified. Auto-saving active profile...")
                    save_current_profile()
            except Exception as e:
                pass

def listen_socket2(stop_event):
    """Listens on Hyprland IPC socket2 for monitor hotplug events."""
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    xdg_runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    if not sig:
        hypr_dir = os.path.join(xdg_runtime, "hypr")
        if os.path.exists(hypr_dir):
            dirs = [d for d in os.listdir(hypr_dir) if os.path.isdir(os.path.join(hypr_dir, d))]
            if dirs:
                sig = dirs[0]

    if not sig:
        print("[monitor_profile_manager] HYPRLAND_INSTANCE_SIGNATURE not found", file=sys.stderr)
        return

    sock_path = os.path.join(xdg_runtime, "hypr", sig, ".socket2.sock")
    if not os.path.exists(sock_path):
        print(f"[monitor_profile_manager] Socket path {sock_path} missing.", file=sys.stderr)
        return

    print(f"[monitor_profile_manager] Daemon listening for hotplug events on {sock_path}...")
    while not stop_event.is_set():
        try:
            s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            s.connect(sock_path)
            with s.makefile("r") as f:
                for line in f:
                    if stop_event.is_set():
                        break
                    line = line.strip()
                    if line.startswith("monitoradded>>") or line.startswith("monitorremoved>>"):
                        print(f"[monitor_profile_manager] Hotplug event received: {line}")
                        time.sleep(1.0) # settle driver
                        auto_restore()
        except Exception as e:
            if stop_event.is_set():
                break
            time.sleep(3)

def run_daemon():
    print("[monitor_profile_manager] Starting daemon mode...")
    auto_restore()
    stop_event = threading.Event()

    t_file = threading.Thread(target=watch_monitors_conf, args=(stop_event,), daemon=True)
    t_file.start()

    listen_socket2(stop_event)

def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "auto"
    if cmd in ["--daemon", "daemon"]:
        run_daemon()
    elif cmd == "save":
        save_current_profile()
        print("Profile saved.")
    elif cmd in ["restore", "auto"]:
        auto_restore()
    elif cmd == "hash":
        h, sig, mons = get_setup_signature()
        print(f"Host: {h}\nHash: {sig}\nMonitors ({len(mons)}):")
        for m in mons:
            print(f" - {m['name']}: {m['make']} {m['model']} (s/n: {m['serial']})")
    else:
        print("Usage: monitor_profile_manager.py [auto|save|restore|daemon|hash]")

if __name__ == "__main__":
    main()
