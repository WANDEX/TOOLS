#!/bin/sh
[ ! -z "$1" ] && cp "$1" ~/.config/wallpaper.png
xwallpaper --zoom ~/.config/wallpaper.png
#feh --bg-fill ~/.config/wallpaper.png --no-fehbg
