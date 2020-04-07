#!/bin/sh
# search locally and open man page in $MANPAGER
if [ -t 0 ]; then
    # execute in current $TERMINAL (already spawned)
    man -k . | dmenu -l 30 | awk '{print $1}' | xargs -r man
else
    # spawn $TERMINAL and execute (works with dmenu)
    man -k . | dmenu -l 30 | awk '{print $1}' | xargs -r $TERMINAL -e man
fi

## open man page as pdf in zathura
#man -k . | dmenu -l 30 | awk '{print $1}' | xargs -r man -Tpdf | zathura -
