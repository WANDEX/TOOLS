#!/bin/sh
# dunstify current mpc volume level
DST="string:x-dunst-stack-tag"
volume=$(mpc status | tail -n 1 | sed -E "s/[ ]{3}.*$//; s/volume: //")
case "$volume" in # if contains a substring '%' -> to not show: n/a
    *%*) dunstify -t 1000 -u "low" -h "$DST:mpc_volume" -h "$DST:hi" "$volume" "" ;;
esac
