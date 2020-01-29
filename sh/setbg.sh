#!/bin/sh
[ ! -z "$1" ] && cp "$1" ~/.config/wallpaper.png
xwallpaper "$2" ~/.config/wallpaper.png
