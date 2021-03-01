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
progress=0 # initial value
prefix="[D]"

# get (window id) of the terminal with ytdl download from summary of first notification
fwid=$(echo "$summary" | grep -o "(.*)" | sed "s/[()]//g")
lindx=$(echo "$summary" | grep -o "{.*}" | sed "s/[{}]//g") # last playlist index
[ -z "$lindx" ] && lindx=1 # if empty
[ "$lindx" -gt 1 ] && prefix="$lindx""$prefix" # 3[D]

cxprop() { xprop -id "$fwid" WM_ICON_NAME | cut -d '"' -f 2 ; } # see xprop value

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
        "$prefix $summary" "$body"
}

# this WM_ICON_NAME value is set via dunst_download_completed.sh
while [ "$(cxprop)" != "DOWNLOAD_COMPLETED" ]; do
    get_summary
    notify
    sleep 2
done
# set window properties back
xdotool set_window --name "$TERMINAL" "$fwid" # set name (because ytdl will leave '...100%...')
xprop -id "$fwid" -remove WM_ICON_NAME # remove property (as it's default in st)
