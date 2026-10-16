#!/usr/bin/env python3
"""
Monitor Profile Manager for Hyprland
Automates monitor layout saving and restoration based on host + connected monitor hardware signatures.

Features:
- Hashes host + connected monitor EDIDs/specs (ignoring volatile port names) to identify unique display setups.
- Dynamically remaps connector names when restoring if ports changed.
- Saves nwg-displays layouts (~/.config/hypr/monitors.conf) to host-specific profile directories (~/.config/hypr/monitor_profiles/<hostname>/).
- Restores saved layouts automatically when connecting to known monitor setups.
- Debounces socket2 hotplug events to avoid capturing transient states.
- Does not auto-create profiles for unknown setups to prevent saving broken defaults.
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

_last_restore_time = 0.0

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
    # Sort deterministically by hardware identity (ignoring connector name)
    for m in sorted(connected_monitors, key=lambda x: (x.get("make", ""), x.get("model", ""), x.get("serial", ""), x.get("description", ""))):
        make = m.get("make", "").strip()
        model = m.get("model", "").strip()
        serial = m.get("serial", "").strip()
        desc = m.get("description", "").strip()
        name = m.get("name", "").strip()
        # Hardware identity without volatile connector name
        spec_str = f"{make}:{model}:{serial}:{desc}"
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

def remap_ports(content, saved_monitors, current_monitors):
    """
    Remaps connector names in saved configuration content if physical monitors
    are plugged into different ports.
    """
    curr_pool = list(current_monitors)
    port_map = {}
    for sm in saved_monitors:
        sm_key = (sm.get("make"), sm.get("model"), sm.get("serial"), sm.get("description"))
        match = None
        for cm in curr_pool:
            cm_key = (cm.get("make"), cm.get("model"), cm.get("serial"), cm.get("description"))
            if sm_key == cm_key:
                match = cm
                break
        if match:
            curr_pool.remove(match)
            if sm.get("name") and match.get("name") and sm["name"] != match["name"]:
                port_map[sm["name"]] = match["name"]

    if not port_map:
        return content

    new_lines = []
    for line in content.splitlines(keepends=True):
        replaced = False
        for old_p, new_p in port_map.items():
            if line.strip().startswith(f"monitor={old_p},"):
                new_lines.append(line.replace(f"monitor={old_p},", f"monitor={new_p},", 1))
                replaced = True
                break
            elif line.strip().startswith("workspace=") and f",{old_p}" in line:
                new_lines.append(line.replace(f",{old_p}", f",{new_p}"))
                replaced = True
                break
        if not replaced:
            new_lines.append(line)
    return "".join(new_lines)

def save_current_profile(force=False):
    """Saves the active ~/.config/hypr/monitors.conf to current monitor profile."""
    ensure_dirs()
    hostname, sig_hash, mon_info = get_setup_signature()
    if not sig_hash or not os.path.exists(MONITORS_CONF):
        return

    # Sanity check: do not auto-save fallback/intermediate files missing rules
    if not force:
        try:
            with open(MONITORS_CONF, "r") as f:
                rules = [l.strip() for l in f if l.strip().startswith("monitor=")]
            if len(mon_info) > 1 and len(rules) < len(mon_info):
                print(f"[monitor_profile_manager] Skipped auto-save: {len(mon_info)} displays connected but monitors.conf only has {len(rules)} rules.")
                return
        except Exception:
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
    global _last_restore_time
    ensure_dirs()
    hostname, sig_hash, mon_info = get_setup_signature()
    if not sig_hash:
        return

    profile_conf = os.path.join(CONFIG_DIR, f"{sig_hash}.conf")
    profile_json = os.path.join(CONFIG_DIR, f"{sig_hash}.json")

    # If profile exists in dotfiles but not in config, sync it over
    if not os.path.exists(profile_conf) and os.path.exists(DOTFILES_DIR):
        dot_conf = os.path.join(DOTFILES_DIR, f"{sig_hash}.conf")
        dot_json = os.path.join(DOTFILES_DIR, f"{sig_hash}.json")
        if os.path.exists(dot_conf):
            shutil.copy2(dot_conf, profile_conf)
            if os.path.exists(dot_json):
                shutil.copy2(dot_json, profile_json)

    if os.path.exists(profile_conf):
        try:
            with open(profile_conf, "r") as f:
                saved_content = f.read()

            saved_monitors = []
            if os.path.exists(profile_json):
                with open(profile_json, "r") as f:
                    saved_monitors = json.load(f).get("monitors", [])

            remapped_content = remap_ports(saved_content, saved_monitors, mon_info)

            current_content = ""
            if os.path.exists(MONITORS_CONF):
                with open(MONITORS_CONF, "r") as f:
                    current_content = f.read()

            if remapped_content.strip() != current_content.strip():
                _last_restore_time = time.time()
                with open(MONITORS_CONF, "w") as f:
                    f.write(remapped_content)
                print(f"[monitor_profile_manager] Restored layout for setup {sig_hash}")
                subprocess.run(["hyprctl", "reload"], check=False)
                notify("Monitor Layout Auto-Restored", f"Applied saved profile for {len(mon_info)} display(s) [{sig_hash}]")
        except Exception as e:
            print(f"[monitor_profile_manager] Error restoring profile: {e}", file=sys.stderr)
    else:
        # Do not auto-save unconfigured/fallback setup for unknown combinations
        print(f"[monitor_profile_manager] Unrecognized monitor setup ({sig_hash}). No profile saved.")
        notify("Monitor Setup Detected", f"Unrecognized display setup [{sig_hash}]. Configure layout with nwg-displays, then save.")

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
                    # Ignore modification if written by auto_restore
                    if time.time() - _last_restore_time < 3.0:
                        continue
                    print("[monitor_profile_manager] monitors.conf modified. Checking if valid to save...")
                    save_current_profile(force=False)
            except Exception as e:
                pass

def listen_socket2(stop_event):
    """Listens on Hyprland IPC socket2 for monitor hotplug events with debouncing."""
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

    debounce_timer = None
    debounce_lock = threading.Lock()

    def debounced_restore():
        if not stop_event.is_set():
            auto_restore()

    def schedule_restore():
        nonlocal debounce_timer
        with debounce_lock:
            if debounce_timer is not None:
                debounce_timer.cancel()
            debounce_timer = threading.Timer(2.5, debounced_restore)
            debounce_timer.daemon = True
            debounce_timer.start()

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
                        print(f"[monitor_profile_manager] Hotplug event received: {line} (debouncing 2.5s)")
                        schedule_restore()
        except Exception as e:
            if stop_event.is_set():
                break
            time.sleep(3)

    with debounce_lock:
        if debounce_timer is not None:
            debounce_timer.cancel()

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
        save_current_profile(force=True)
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
