#!/usr/bin/env bash

awww-daemon & 
sleep 1
# awww img ~/Wallpapers/jwst_1.png & 
awww img ~/.dotfiles/wallpapers/backgroundblend.png &

# networking applet
nm-applet --indicator &

# bluetooth 
blueman-applet &

waybar & 

swayidle -w \
  before-sleep 'swaylock -f' \
  after-resume '~/.dotfiles/home/hyprland/scripts/refresh-graphics.sh' &

mako &
