#!/bin/sh
# change notification text that stream is started with full stream path at body
# and add ACTION into notification
appname="$1"
summary="$2"
body="$3"
icon="$4"
urgency="$5"

# extract channel name
twitch_channel=$(echo "$summary" | sed "s/ is .*$//")
url="https://www.twitch.tv/""$twitch_channel"
summary="🔴 $twitch_channel LIVE:"
body="\n$url"

ACTION=$(dunstify -u "$urgency" -A "default,mpvu" -A "clip,url" "$summary" "$body")

case "$ACTION" in
"default")
    setsid -f mpvu -u "$url"
    ;;
"clip")
    clipargs "$url"
    ;;
esac
