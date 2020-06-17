#!/bin/sh
# sed for editing i3 & py3status configs
PATH_I3CONFIG="$HOME"'/.config/i3/config'
PATH_PY3STATUS="$HOME"'/.config/py3status/config'

## AUDIO SINK
# get sink number of hdmi
# replace 'set $sink1 *' with SINK1
sed -i 's,^set $sink1.*$,set $sink1 '"${SINK1}"',' $PATH_I3CONFIG
# replace 'device = "*" # flag4sed M with SINK1
sed -i 's,device = ".*" # flag4sed M,device = "'"${SINK1}"'" # flag4sed M,' $PATH_PY3STATUS

## DISPLAY OUTPUTS
# replace 'set $output0 *' with current output name
sed -i 's,^set $output0.*$,set $output0 '\""${OUT0}"\"',' $PATH_I3CONFIG
# replace 'set $output1 *' with current output name
sed -i 's,^set $output1.*$,set $output1 '\""${OUT1}"\"',' $PATH_I3CONFIG

sleep 5
i3 restart
