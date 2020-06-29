#!/bin/sh
# env OUTS declared in pam env /etc/environment
# make sure nouveau not blacklisted, usually in /usr/lib/modprobe.d/nvidia.conf
# https://wiki.archlinux.org/index.php/Nouveau
xrandr --output $OUT0 --rate 60 --pos 0x0 --primary &&
xrandr --output $OUT1 --rate 60 --pos 1920x0 &&
xrandr --setmonitor BenQ\ EW2440L 1920/531x1080/298+0+0 $OUT0 &&
xrandr --setmonitor Samsung\ SyncMaster 1280/375x1024/300+1920+0 $OUT1

