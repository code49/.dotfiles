#!/usr/bin/env bash

swww init & 
# swww img ~/Wallpapers/jwst_1.png & 
swww img ~/.dotfiles/wallpapers/backgroundblend.png &

# networking applet
nm-applet --indicator &

# bluetooth 
blueman-applet &

waybar & 

swayidle -w before-sleep 'swaylock -f' &

mako & 

# firefox initial pages; spotify + notion, personal site + blank google
nohup /run/current-system/sw/bin/firefox -p dchan-personal 'https://www.notion.so/davidlechan/d03cd6231ead496e808bdf0fe03f8566' 'https://open.spotify.com' &
nohup /run/current-system/sw/bin/firefox -p dchan-personal 'https://calendar.google.com' 'https://davidlechan.dev' &
