#!/usr/bin/env python3
import json
import subprocess
import sys

def run_cmd(cmd):
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return result.stdout.strip()

def main():
    if len(sys.argv) < 2:
        print("Usage: swapcol_nowrap.py <l|r>")
        sys.exit(1)
    direction = sys.argv[1]
    if direction not in ("l", "r"):
        print("Invalid direction. Must be 'l' or 'r'.")
        sys.exit(1)

    # 1. Get active window
    active_win_json = json.loads(run_cmd(["hyprctl", "activewindow", "-j"]))
    active_address = active_win_json.get("address")
    active_workspace = active_win_json.get("workspace", {}).get("id")

    if not active_address or active_workspace is None:
        print("Error: Could not get active window details.")
        sys.exit(1)

    # 2. Get all clients on the active workspace
    clients = json.loads(run_cmd(["hyprctl", "clients", "-j"]))
    workspace_clients = [c for c in clients if c.get("workspace", {}).get("id") == active_workspace and not c.get("floating")]

    # Group all workspace clients into columns by their x coordinate (with 10px tolerance)
    columns_map = {}
    for c in workspace_clients:
        x = c["at"][0]
        found = False
        for cx in columns_map:
            if abs(cx - x) < 10:
                columns_map[cx].append(c)
                found = True
                break
        if not found:
            columns_map[x] = [c]

    # Sort columns by their average X coordinate
    sorted_x = sorted(columns_map.keys())

    # Find active column index
    active_col_idx = -1
    for i, x in enumerate(sorted_x):
        if any(c["address"] == active_address for c in columns_map[x]):
            active_col_idx = i
            break

    if active_col_idx == -1:
        print("Error: Active column not found.")
        sys.exit(1)

    # 3. Check boundaries
    if direction == "l" and active_col_idx == 0:
        print("Leftmost column. Cannot swap left.")
        return
    if direction == "r" and active_col_idx == len(sorted_x) - 1:
        print("Rightmost column. Cannot swap right.")
        return

    # 4. Dispatch native swapcol
    run_cmd(["hyprctl", "dispatch", "layoutmsg", f"swapcol {direction}"])

if __name__ == "__main__":
    main()
