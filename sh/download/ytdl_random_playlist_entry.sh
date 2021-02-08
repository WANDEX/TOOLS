#!/bin/sh
# select one random element from playlist, get json info and open url in mpv

URL="${1:-$(xclip -selection clipboard -out)}"
case "$URL" in
    *"youtu"*"playlist"*) INFO=$(youtube-dl -j --flat-playlist "$URL" | shuf -n 1) ;;
    *) notify-send "[ERROR]: given URL is not youtube playlist" "\n$url" && exit 1 ;;
esac >/dev/null

title=$(echo "$INFO" | jq -r '.title')
watch=$(echo "$INFO" | jq -r '.url')
seconds=$(echo "$INFO" | jq -r '.duration')
duration=$(date -d@"$seconds" -u +%H:%M:%S)
url='https://www.youtube.com/watch?v='"$watch"
notify-send "$title" "\n[$duration] $url"
mpvu -q audio --quiet --end 1 --url "$url"
