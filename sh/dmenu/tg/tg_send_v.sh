#!/bin/sh
# select video from dir and subdirs via dmenu
# copy selected video path to clipboard and send it via tg
# in pre-opened recipient dialog! tdesktop shortcut: Send File Ctrl + O
DIR="$HOME"'/Films/.mpv_encode/tg'

# find all files at path and ignore hidden .dot files
names="$(find "$DIR" -type f \( ! -iname ".*" \) -printf '%f\n')"
selection=$(echo "$names" | dmenu -i -p '(TG) choose video to send:' -l 30)
[ -z "$selection" ] && exit 0
# FIXME DOES NOT Escapes unusual characters on filenames!
full_path="$(find "$DIR" -type f \( -name "$selection" \))"
if [ ! -f "$full_path" ]; then
    notify-send -u critical "[tg_send] ERROR: file not found:" "\n$full_path\n"
    exit 1
fi

# add to clipboard
echo "$full_path" | xclip -in -sel clip -r

# get tg PID
PID=$(xdotool search --class TelegramDesktop getwindowpid)
# in pre-opened recipient dialog! - open file select window
xdotool search --all --pid "$PID" --name "Telegram" key --clearmodifiers ctrl+o
# paste full path -> select file
xdotool search --sync --onlyvisible --all --pid "$PID" --name "Choose files" key --clearmodifiers ctrl+v Return
xdotool keyup Return

