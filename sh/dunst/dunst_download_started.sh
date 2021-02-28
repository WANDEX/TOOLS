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
progress=0 # initial value (so as not to break the while loop)
counter=0
letter="[D]"
prefix="$letter"

get_summary() {
    wtitle=$(xprop -id "$fwid" WM_NAME | cut -d '"' -f 2) # get window title
    summary=$(echo "$wtitle" | sed "s/youtube-dl[ ]*//") # remove ytdl (removing spaces)
    progress=$(echo "$summary" | sed "s/[.,%].*$//; s/[ ]*//g") # get only int value
    [ "$lindx" -gt 1 ] && prefix="${i}/${lindx}$letter" # 1/3[D]
    case "$progress" in
        # this comes if variable contains non int characters
        # if progress not yet available -> initial value
        ''|*[!0-9]*)
            progress=0
            counter=$(echo "$counter + 1" | bc)
            ;;
    esac
}

notify() {
    # body is title so it is unchanged
    dunstify -u "$urgency" \
        -h "string:x-dunst-stack-tag:dp_$fwid" \
        -h "int:value:$progress" \
        "$prefix $summary" "$body"
}

# get (window id) of the terminal with ytdl download from summary of first notification
fwid=$(echo "$summary" | grep -o "(.*)" | sed "s/[()]//g")
lindx=$(echo "$summary" | grep -o "{.*}" | sed "s/[{}]//g") # last playlist index
[ -z "$lindx" ] && lindx=1 # if empty
for i in $(seq "$lindx"); do
    while [ "$counter" -lt 10 ] && [ "$progress" -ne 100 ]; do
        get_summary
        notify
        [ "$progress" -gt 90 ] && [ "$i" -ne "$lindx" ] && break
        sleep 2
    done
    counter=0
done
# set window title back to $TERMINAL name (because ytdl will leave '...100%...')
xdotool set_window --name "$TERMINAL" "$fwid"
