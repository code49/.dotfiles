#!/usr/bin/env bash

swww-daemon & 
# swww img ~/Wallpapers/jwst_1.png & 
swww img ~/.dotfiles/wallpapers/backgroundblend.png &

# networking applet
nm-applet --indicator &

# bluetooth 
blueman-applet &

waybar & 

swayidle -w before-sleep 'swaylock -f'

mako 
