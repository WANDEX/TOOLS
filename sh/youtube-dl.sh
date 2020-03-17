#!/bin/sh
URL=$(xclip -o)
VTITLE=$(youtube-dl --get-title "$URL")
TITLE="$VTITLE"' - YTDL'
WEBM='bestvideo[ext=webm][height<=?1080]+bestaudio[ext=webm]'
FALLBACK='bestvideo[height<=?1080]+bestaudio/best'
FORMAT="$WEBM"'/'"$FALLBACK"

notify-send -t 5000 "Playing..." "$TITLE"
mpv --title="$TITLE" --ytdl-format="$FORMAT" "$URL"
