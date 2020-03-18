#!/bin/sh
URL=$(xclip -o)
VTITLE=$(youtube-dl --get-title "$URL")
WEBM='bestvideo[ext=webm][height<=?1080]+bestaudio[ext=webm]'
FALLBACK='bestvideo[height<=?1080]+bestaudio/best'
FORMAT="$WEBM"'/'"$FALLBACK"

if [[ "$URL" == *"videos"* ]]; then
    PROFILE='vods'
elif [[ "$URL" == *"twitch"* ]]; then
    PROFILE='stream'
else
    PROFILE='ytdl'
fi

STATUS='Playing...['"$PROFILE"']'
TITLE="$VTITLE"' | '"$PROFILE"' [YTDL]'

notify-send -t 5000 "$STATUS" "$TITLE"
mpv --title="$TITLE" --ytdl-format="$FORMAT" --profile="$PROFILE" "$URL"
