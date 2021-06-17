#!/bin/bash
# requires sudo for updating servers in '/etc/pacman.d/mirrorlist'

sudo reflector -p https --age 24 --fastest 50 --latest 25 --sort rate \
    --download-timeout 30 --save /etc/pacman.d/mirrorlist && \
    notify-send "🆙 $(basename $0)" "mirrorlist updated" || \
    notify-send -u critical "🆙 $(basename $0)" "error"
rm -f /etc/pacman.d/mirrorlist.pacnew && \
    notify-send -u low "🆙 $(basename $0)" "rm -f is OK" || \
    notify-send -u critical "🆙 $(basename $0)" "rm error"
