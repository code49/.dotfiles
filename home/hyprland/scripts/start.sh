#!/usr/bin/env bash

# using this to initialize all

swww init & 
# swww img ~/Wallpapers/jwst_1.png & 
swww img ~/.dotfiles/wallpapers/backgroundblend.png &

# networking applet
nm-applet --indicator &

# bluetooth 
blueman-applet &

# top status bar
# waybar &

# lockscreen
swayidle -w before-sleep 'swaylock -f' &

# notifications handler
mako & 
