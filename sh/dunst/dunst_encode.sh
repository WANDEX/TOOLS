#!/bin/sh
# show notification when process with encoding is finished (vanished)
# and add ACTION to copy $out_path to clipboard or open video in mpv
appname="$1"
summary="$2"
body="$3"
icon="$4"
urgency="$5"

summary="$(echo "$summary" | sed "s/ENCODEME/ENCODE/")"
summary="$(echo "$summary" | sed "s/STARTED/FINISHED/")"
out_path=$(echo "$body" | grep -o "(.*)" | sed "s/[()]//g")
H="string:x-dunst-stack-tag:dp_$out_path"
body=$(echo "$body" | sed "s/(.*)//g") # remove (out_path) from body

# wait till ffmpeg process with $out_path in command line is finished (vanished)
pwait -u "$USER" -f "ffmpeg .*$out_path"

ACTION=$(dunstify -u "$urgency" -h "$H" -A "default,clip,path" -A "mpv,open" -A "reencode,tg" "$summary" "\n$body")

case "$ACTION" in
"default")
    clipargs "$out_path"
    ;;
"mpv")
    setsid -f mpv "$out_path"
    ;;
"reencode")
    setsid -f convert_tg.sh
    ;;
esac
