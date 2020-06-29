#!/bin/sh
# select video from .mpv_encode/tg/ dir and subdirs via dmenu
# copy selected video path to clipboard and send it via tg
# in pre-opened recipient dialog! tdesktop shortcut: Send File Ctrl + O
DIR="$HOME"'/Films/.mpv_encode/'
DIR_TG="$DIR"'tg/'

# find all files at path and ignore hidden .dot files
files="$(find "$DIR_TG" -type f \( ! -iname ".*" \))"
names="$(basename --multiple $files)"
echo "$names" | dmenu -i -p '(TG) choose video to send: ' -l 30 | xclip -in || exit 0
selection="$(xclip -out)""*"
full_path="$(find "$DIR_TG" -type f \( -iname "$selection" \))"
# add to clipboard
echo "$full_path" | xclip -in -sel clip -r

# get tg PID
PID=$(xdotool search --class TelegramDesktop getwindowpid)
# in pre-opened recipient dialog! - open file select window
xdotool search --all --pid $PID --name "Telegram" key --clearmodifiers ctrl+o
# paste full path -> select file
xdotool search --sync --onlyvisible --all --pid $PID --name "Choose files" key --clearmodifiers ctrl+v Return
xdotool keyup Return

