#!/bin/sh
# sed for editing i3 & py3status configs
PATH_I3CONFIG=''"$HOME"'/.config/i3/config'
PATH_PY3STATUS=''"$HOME"'/.config/py3status/config'

## AUDIO SINK
# get sink number of hdmi
SINK_N1=$(pactl list sinks short | grep 'hdmi' | awk {'print $1'})
# replace 'set $sink1 *' with SINK_N1 number
sed -i 's,^set $sink1.*$,set $sink1 '"${SINK_N1}"',' $PATH_I3CONFIG
# replace 'device = "*" # flag4sed M with SINK_N1 number
sed -i 's,device = ".*" # flag4sed M,device = "'"${SINK_N1}"'" # flag4sed M,' $PATH_PY3STATUS

## MONITOR OUTPUTS
# replace 'set $output0 *' with current output name
sed -i 's,^set $output0.*$,set $output0 '\""${OUT0}"\"',' $PATH_I3CONFIG
# replace 'set $output1 *' with current output name
sed -i 's,^set $output1.*$,set $output1 '\""${OUT1}"\"',' $PATH_I3CONFIG

sleep 5
i3 restart
