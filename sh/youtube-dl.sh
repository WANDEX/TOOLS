#!/bin/sh

# use $1 or default
URL="${1:-$(xclip -selection clipboard -out)}"

# substring
case "$URL" in
    *"videos"*)
        PROFILE='vods'
    ;;
    *"twitch"*)
        PROFILE='stream'
    ;;
    *)
        PROFILE='ytdl'
    ;;
esac >/dev/null

WEBM='bestvideo[ext=webm][height<=?1080]+bestaudio[ext=webm]'
FALLBACK='bestvideo[height<=?1080]+bestaudio/best'
FORMAT="$WEBM"'/'"$FALLBACK"
VTITLE=$(youtube-dl --get-title "$URL")
STATUS='Playing...['"$PROFILE"']'
TITLE="$VTITLE"' | '"$PROFILE"' [YTDL]'

notify-send -t 5000 "$STATUS" "$TITLE"
mpv --title="$TITLE" --ytdl-format="$FORMAT" --profile="$PROFILE" "$URL"
