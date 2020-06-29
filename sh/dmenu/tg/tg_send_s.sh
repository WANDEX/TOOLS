#!/bin/sh
# select screenshot from dir and subdirs via dmenu
# copy selected screenshot path to clipboard and send it via tg
# in pre-opened recipient dialog! tdesktop shortcut: Send File Ctrl + O
DIR="$HOME"'/Downloads/Pictures/mpv_screen'

# find all files at path and ignore hidden .dot files
files="$(find "$DIR" -type f \( ! -iname ".*" \))"
names="$(basename --multiple $files | sort -nr)"
echo "$names" | dmenu -i -p '(TG) choose screenshot to send: ' -l 30 | xclip -in || exit 0
selection="$(xclip -out)""*"
full_path="$(find "$DIR" -type f \( -iname "$selection" \))"
# add to clipboard
echo "$full_path" | xclip -in -sel clip -r

# get tg PID
PID=$(xdotool search --class "telegram-desktop" getwindowpid)
# get tg window id
#WID=$(xdotool search --class "telegram-desktop" | head -1)
#xdotool windowactivate --sync "$WID"

#sleep 1.5
#wait

# in pre-opened recipient dialog! - open file select window
# broken right now
xdotool search --all --pid $PID --name "Telegram" key --clearmodifiers ctrl+o
# paste full path -> select file
xdotool search --sync --onlyvisible --all --pid $PID --name "Choose files" key --clearmodifiers ctrl+v Return
xdotool keyup Return

