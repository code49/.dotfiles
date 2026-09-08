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
        
    if active_ws is None:
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
    # This preserves the left-to-right ordering of columns in scrolling/tiled layouts
    current_clients.sort(key=lambda c: c.get("at", [0, 0])[0])
    
    # Build batch commands to move each window and restore its exact pixel dimensions
    batch_cmds = []
    for c in current_clients:
        addr = c["address"]
        batch_cmds.append(f"dispatch movetoworkspacesilent {target_ws},address:{addr}")
        
        size = c.get("size", [])
        if len(size) == 2 and size[0] > 0 and size[1] > 0:
            w, h = size[0], size[1]
            batch_cmds.append(f"dispatch resizewindowpixel exact {w} {h},address:{addr}")

    # Switch focus to the target workspace so the user follows the windows
    batch_cmds.append(f"dispatch workspace {target_ws}")

    # Execute all operations atomically in a single hyprctl batch call
    try:
        run_cmd(["hyprctl", "--batch", " ; ".join(batch_cmds)])
    except Exception as e:
        print(f"Error executing batch workspace move: {e}")
        # Fallback to individual command dispatches
        for c in current_clients:
            addr = c["address"]
            run_cmd(["hyprctl", "dispatch", "movetoworkspacesilent", f"{target_ws},address:{addr}"])
            size = c.get("size", [])
            if len(size) == 2 and size[0] > 0 and size[1] > 0:
                run_cmd(["hyprctl", "dispatch", "resizewindowpixel", f"exact {size[0]} {size[1]},address:{addr}"])
        run_cmd(["hyprctl", "dispatch", "workspace", target_ws])

if __name__ == "__main__":
    main()

