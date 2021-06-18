#!/bin/sh
# select screenshot from dir and subdirs via dmenu
# copy selected screenshot path to clipboard and send it via tg
# in pre-opened recipient dialog! tdesktop shortcut: Send File Ctrl + O
DIR="$HOME"'/Downloads/Pictures/mpv_screen'

# find all files at path and ignore hidden .dot files
names="$(find "$DIR" -type f \( ! -iname ".*" \) -printf '%f\n' | sort -nr)"
selection="$(echo "$names" | dmenu -i -p '(TG) choose screenshot to send:' -l 30)"
[ -z "$selection" ] && exit 0
full_path="$DIR/$selection"
if [ ! -f "$full_path" ]; then
    notify-send -u critical "[tg_send] ERROR: file not found:" "\n$full_path\n"
    exit 1
fi

# add to clipboard
echo "$full_path" | xclip -in -sel clip -r

# get tg PID
PID=$(xdotool search --class "telegram-desktop" getwindowpid)
# in pre-opened recipient dialog! - open file select window
xdotool search --all --pid "$PID" --name "Telegram" key --clearmodifiers ctrl+o
# paste full path -> select file
xdotool search --sync --onlyvisible --all --pid "$PID" --name "Choose files" key --clearmodifiers ctrl+v Return
xdotool keyup Return

