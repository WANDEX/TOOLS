#!/bin/bash
# requires sudo for updating servers in '/etc/pacman.d/mirrorlist'
reflector -p https --age 24 --fastest 50 --latest 25 --sort rate --save /etc/pacman.d/mirrorlist; rm -f /etc/pacman.d/mirrorlist.pacnew
