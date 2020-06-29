#!/bin/sh
nvidia-settings --assign CurrentMetaMode="$OUT0: 1920x1080_60 +0+0, $OUT1: 1280x1024_60 +1920+0" &&
xrandr --output $OUT0 --primary
