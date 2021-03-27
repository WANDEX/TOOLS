#!/bin/sh
# toggle Internet access.
# sudo commands - requires sudo password
DST="string:x-dunst-stack-tag"
if route -v | grep -q "default" ; then
    sudo route del default gw 192.168.1.1 &&
    dunstify -t 3000 -u critical -h "$DST:Internet_toggle" -h "$DST:hi" "OFF - default gateway deleted."
else
    # requires sudo password
    sudo route add default gw 192.168.1.1 &&
    dunstify -t 3000 -u critical -h "$DST:Internet_toggle" -h "$DST:hi" "ON - default gateway added."
fi
