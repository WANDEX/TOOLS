#!/bin/sh
# create dynamic ytdl download progress notification
# default ytdl window title with --console-title option:
# when downloading: "youtube-dl  30.3% of 432.50MiB at  4.27MiB/s ETA 01:10"
# when downloaded:  "youtube-dl 100% of 12.36MiB in 00:01"
appname="$1"
summary="$2"
body="$3"
icon="$4"
urgency="$5"

get_summary() {
    wtitle=$(xprop -id "$fwid" WM_NAME | cut -d '"' -f 2) # get window title
    summary=$(echo "$wtitle" | sed "s/youtube-dl[ ]*//") # remove ytdl (removing spaces)
    progress=$(echo "$summary" | sed "s/[.,%].*$//; s/[ ]*//g") # get only int value
    case "$progress" in # this comes if variable contains non int characters
        ''|*[!0-9]*) progress=0 ;; # if progress not yet available -> initial value
    esac
}

notify() {
    # body is title so it is unchanged
    dunstify -u "$urgency" \
        -h "string:x-dunst-stack-tag:dp_$fwid" \
        -h "int:value:$progress" \
        "[D] $summary" "$body"
}

# get (window id) of the terminal with ytdl download from summary of first notification
fwid=$(echo "$summary" | grep -o "(.*)" | sed "s/[()]//g")
progress=0 # initial value (so as not to break the while loop)
while [ "$progress" -lt 100 ]; do
    get_summary
    notify
    sleep 2
done
# set window title back to $TERMINAL name (because ytdl will leave '...100%...')
xdotool set_window --name "$TERMINAL" "$fwid"
