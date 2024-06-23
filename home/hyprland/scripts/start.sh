#!/usr/bin/env bash

swww init & 
# swww img ~/Wallpapers/jwst_1.png & 
swww img ~/.dotfiles/wallpapers/shark_coral_background_1_upscale.jpg &

# networking applet
nm-applet --indicator &

# bluetooth 
blueman-applet &

waybar & 

mako 
