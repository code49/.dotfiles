#!/usr/bin/env bash

set -eu

# Let the compositor and DRM display stack finish resuming before reloading state.
sleep 2.5

hyprctl dispatch dpms on || true

# Restart desktop portal service to recover from destroyed Wayland object references post-suspend
systemctl --user restart xdg-desktop-portal.service || true

python3 ~/.dotfiles/home/hyprland/scripts/monitor_fallback.py || true
