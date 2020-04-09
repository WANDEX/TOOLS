#!/bin/sh
# Download in Music dir audio only stream and convert to audio file format

MUSIC="$HOME"'/Music/'
# use $1 or default
URL="${1:-$(xclip -selection clipboard -out)}"
END="${2:--1}"
OUT="${3:-"$MUSIC"}"

# substring
case "$URL" in
    *"bandcamp"*)
        OUT+='~bandcamp/%(playlist)s/%(playlist_index)02d. %(title)s.%(ext)s'
    ;;
    *"soundcloud"*"/sets/"*)
        OUT+='~soundcloud/%(uploader)s/%(playlist)s/%(playlist_index)02d. %(fulltitle)s.%(ext)s'
    ;;
    *"soundcloud"*)
        OUT+='~soundcloud/%(uploader)s/%(playlist)s/%(fulltitle)s.%(ext)s'
    ;;
    *"youtu"*)
        OUT+='~youtube/%(playlist_title)s/%(playlist_index)02d. %(title)s.%(ext)s'
    ;;
    *)
        OUT+='~other/%(title)s.%(ext)s'
    ;;
esac >/dev/null

BEST='bestaudio[asr=48000]'
FALLBACK='bestaudio/best'
FORMAT="$BEST"'/'"$FALLBACK"
notify-send -t 3000 "Downloading..."
time youtube-dl --ignore-errors --yes-playlist --playlist-end="$END" \
    --format "$FORMAT" --output "$OUT" --restrict-filenames \
    --extract-audio --audio-format "mp3" "$URL" && \
    notify-send -u normal -t 8000 "COMPLETED" "Downloading and Converting." || \
    notify-send -u critical -t 5000 "ERROR" "Something gone wrong!"

