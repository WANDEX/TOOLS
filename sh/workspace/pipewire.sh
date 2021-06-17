#!/bin/sh
# script for pipewire/pulse-audio -> combined sink creation and defaults
# aplay -lL
# pw-jack jack_lsp -c
# ? check for device availability
# fuser -v /dev/snd/*
# fuser -v /dev/dsp

# ENVD defined in /etc/environment
[ -z "$ENVDIR" ] && ENVDIR="$ENVD"
# source env variables if not defined at the exec time (for .xinitrc etc.)
[ -z "$SINK0" ] && . "$ENVDIR/scripts/get_dflt_sink"
[ -z "$SINK1" ] && . "$ENVDIR/scripts/get_hdmi_sink"

# source even if $SINK0 & $SINK1 defined at the exec time (overrides above)
. "$ENVDIR/scripts/get_dflt_sink"
. "$ENVDIR/scripts/get_hdmi_sink"

#pw-jack jack_control start
#pw-jack jack_control ds alsa
#pw-jack jack_control dps device hw:PCH
#pw-jack jack_control dps rate 48000

# or should be this?
#pw-jack jack_control dps device hw:PCH,0

pactl list sinks short | grep -q "combined" # 0 if found
if [ "$?" -ne 0 ]; then
    # create
    pactl load-module module-null-sink object.linger=1 media.class=Audio/Sink sink_name=combined channel_map=stereo
    # connect
    pw-jack jack_connect "combined Audio/Sink sink:monitor_FL" "HDA Intel PCH:playback_FL"
    pw-jack jack_connect "combined Audio/Sink sink:monitor_FR" "HDA Intel PCH:playback_FR"
fi

pw-jack jack_lsp -c | grep -q "   HDA NVidia:"
if [ "$?" -eq 1 ]; then
    sleep 5
    # connect
    pw-jack jack_connect "combined Audio/Sink sink:monitor_FL" "HDA NVidia:playback_FL"
    pw-jack jack_connect "combined Audio/Sink sink:monitor_FR" "HDA NVidia:playback_FR"
fi

# set
pactl set-default-sink combined
pactl set-default-source combined.monitor

# volume: 32768=50%, 45875=70%, 65536=100%, 78642=120%
pactl set-sink-volume "$SINK0" 45875
pactl set-sink-volume "$SINK1" 32768
pactl set-sink-mute "$SINK1" true # mute at boot sink N
