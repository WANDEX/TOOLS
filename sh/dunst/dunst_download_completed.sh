#!/bin/sh
# stop inf loop in dunst_download_started.sh
# and replace original notification about download completion
appname="$1"
summary="$2"
body="$3"
icon="$4"
urgency="$5"

fwid=$(echo "$summary" | grep -o "(.*)" | sed "s/[()]//g")
summary=$(echo "$summary" | sed "s/(.*)//g") # remove (fwid) from summary
dunstify -u "$urgency" -h "string:x-dunst-stack-tag:dp_$fwid" "$summary" "$body"
# we set WM_ICON_NAME as it's infinite loop abort condition in dunst_download_started.sh
xprop -id "$fwid" -set WM_ICON_NAME "DOWNLOAD_COMPLETED"
