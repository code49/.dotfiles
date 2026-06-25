#!/usr/bin/env python3
import sys
import json
import subprocess

def run_cmd(cmd):
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return result.stdout.strip()

def main():
    if len(sys.argv) < 2:
        print("Usage: move_workspace_windows.py <target_workspace>")
        sys.exit(1)
        
    target_ws = sys.argv[1]
    
    # Get active workspace
    try:
        active_ws_data = json.loads(run_cmd(["hyprctl", "activeworkspace", "-j"]))
        active_ws = active_ws_data.get("id")
    except Exception as e:
        print(f"Error getting active workspace: {e}")
        sys.exit(1)
        
    if not active_ws:
        print("Could not determine active workspace.")
        sys.exit(1)
        
    # Get clients
    try:
        clients = json.loads(run_cmd(["hyprctl", "clients", "-j"]))
    except Exception as e:
        print(f"Error getting clients: {e}")
        sys.exit(1)
        
    # Filter clients on the current workspace
    current_clients = [c for c in clients if c.get("workspace", {}).get("id") == active_ws]
    
    if not current_clients:
        print(f"No windows on workspace {active_ws} to move.")
        # Switch to the target workspace
        run_cmd(["hyprctl", "dispatch", "workspace", target_ws])
        sys.exit(0)
        
    # Sort current clients by their horizontal coordinate (at[0])
    # This preserves the left-to-right ordering of columns in the scrolling layout
    current_clients.sort(key=lambda c: c.get("at", [0, 0])[0])
    
    # Move each window silently in sorted order
    for c in current_clients:
        addr = c["address"]
        run_cmd(["hyprctl", "dispatch", "movetoworkspacesilent", f"{target_ws},address:{addr}"])
        
    # Switch focus to the target workspace so the user follows the windows
    run_cmd(["hyprctl", "dispatch", "workspace", target_ws])

if __name__ == "__main__":
    main()
