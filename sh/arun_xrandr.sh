#!/bin/sh
# env OUTS declared in pam env /etc/environment
OUT0=$OUT0
OUT1=$OUT1
xrandr --output $OUT0 --mode 1920x1080 --rate 60 --pos 0x0 --primary &&
xrandr --output $OUT1 --mode 1280x1024 --rate 60 --pos 1920x0 &&
xrandr --setmonitor BENQ_EW2440 1920/531x1080/298+0+0 $OUT0 &&
xrandr --setmonitor SAMSUNG_SyncMaster_931BF 1280/375x1024/300+1920+0 $OUT1 &&
i3 restart
