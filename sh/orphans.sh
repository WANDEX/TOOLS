#!/bin/sh
# remove real orphans (no longer needed packages)
# also use sudo ncdu / or /var to see what to remove to free up space.
# if deal with the pacman cache - sudo pacman -Sc (pacman -Scc to remove all cached files)
sudo pacman -Rns $(pacman -Qqtd)
