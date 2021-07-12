#!/bin/sh
# get track information from notification, to display it in statusbar
# do not show notification
appname="$1"
summary="$2"
body="$3"
icon="$4"
urgency="$5"
DST="string:x-dunst-stack-tag"

CSCRDIR="${CSCRDIR:-"$HOME/.cache/cscripts"}"
FILE="$CSCRDIR/bar/music-web" # hardcoded, check music-web script!

track="$summary"

# replace patterns, delete lines with patterns, 4th line, transform into single line string
artist="$(echo "$body" \
    | sed "s/SoundCloud//g; s/&amp\;/\&/g" \
    | sed "/^.* - Single/d; /^Your scrobbles:.*$/d; /$track/d; 4d" \
    | tr -d '\n')"

# dunstify "$urgency" -u low -t 0 -h "$DST:web-scrobbler" -h "$DST:hi" "$track - $artist"

echo "$track - $artist" > "$FILE" # write to file in order to display via music-web script

# hardcoded SIG! to update dwmblocks
kill -46 "$(pidof dwmblocks)" # refresh music-web
