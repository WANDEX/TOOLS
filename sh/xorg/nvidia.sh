#!/bin/sh
OUT0=$OUT0
OUT1=$OUT1
nvidia-settings --assign CurrentMetaMode="$OUT1: 1280x1024_60 +1920+0, $OUT0: 1920x1080_60 +0+0" &&
xrandr --output $OUT0 --primary &&
i3 restart
