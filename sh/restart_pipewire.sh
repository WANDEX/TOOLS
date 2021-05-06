#!/bin/sh
# restart sound related programs and pipewire itself

pulseeffects --quit

# restart pipewire
systemctl --user restart pipewire.service

# run pipewire defaults configuration
pipewire.sh
wait

mpd --kill
mpd
pkill mpdas
setsid -f mpdas -d
pkill mpdup
setsid -f mpdup
setsid -f pulseeffects --gapplication-service
# use ^C to exit out of junk outputted by pulseeffects to terminal
# WARNINGS etc. dunno how to suppress that...
