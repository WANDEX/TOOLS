#!/bin/sh
# toggle Internet access.
# sudo commands - requires sudo password
if route -v | grep -q "default" ; then
    sudo route del default gw 192.168.1.1 &&
    notify-send --urgency=critical "OFF - default gateway deleted."
else
    # requires sudo password
    sudo route add default gw 192.168.1.1 &&
    notify-send --urgency=critical "ON - default gateway added."
fi
