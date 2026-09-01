#!/usr/bin/env bash

awww-daemon & 
sleep 1
# awww img ~/Wallpapers/jwst_1.png & 
awww img ~/.dotfiles/wallpapers/backgroundblend.png &

# networking applet
nm-applet --indicator &

# bluetooth 
blueman-applet &

systemctl --user restart waybar & 

swayidle -w \
  before-sleep 'swaylock -f' \
  after-resume '~/.dotfiles/home/hyprland/scripts/refresh-graphics.sh' &

mako &

python3 ~/.dotfiles/home/hyprland/scripts/monitor_fallback.py --daemon &
