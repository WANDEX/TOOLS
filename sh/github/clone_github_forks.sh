#!/bin/sh
# One script to git clone all valuable forks
FORKS="$SOURCE"'/forks'
DIR="$FORKS"'/luke'
mkdir -p "$DIR"
cd "$DIR"
git clone git@github.com:WANDEX/dmenu.git
git clone git@github.com:WANDEX/dwm.git
git clone git@github.com:WANDEX/dwmblocks.git
git clone git@github.com:WANDEX/st.git
git clone git@github.com:WANDEX/voidrice.git
cd "$FORKS"
git clone git@github.com:WANDEX/pomodoro.git
git clone git@github.com:WANDEX/mpv-scripts.git
