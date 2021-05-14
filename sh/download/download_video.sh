#!/bin/sh
# download via youtube-dl video playlist or single video

# check if script started from terminal emulator
if [ -t 0 ]; then
    is_term=1
    # get before everything else (to prevent switching to another window)
    fwid=$(xdotool getactivewindow) # get id of the active/focused window
else
    is_term=0
    fwid="empty"
fi

# read into variable using 'Here Document' code block
read -d '' USAGE <<- EOF
Usage: $(basename $BASH_SOURCE) [OPTION...]
OPTIONS
    -b, --begin         Download from playlist index (default:1)
    -e, --end           If url is playlist - how many items to download (default:1)
    -h, --help          Display help
    -i, --interactive   Explicit interactive playlist end mode
    -p, --path          Destination path where to download
    -q, --quality       Quality of video/stream
    -r, --restrict      Restrict filenames to only ASCII characters, and avoid "&" and spaces in filenames
    -u, --url           URL of video/stream
    -y, --ytdl          Any other youtube-dl native options (specify only inside "")
EXAMPLES:
    $(basename $BASH_SOURCE) -u "\$URL" -y "--simulate --get-duration" -y "--playlist-items 1-3"
EOF

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=b:e:hip:rq:u:y:
    LONG=begin:,end:,help,interactive,path:,restrict,quality:,url:,ytdl:
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    OUT="$HOME"'/Films/.yt/'
    START=1    # youtube-dl --playlist-start > download from playlist index
    END=1      # youtube-dl --playlist-end > get first N items from playlist
    ENDOPT=0
    EXT='webm' # prefer certain extension over FALLBACK in youtube-dl
    QLT='1080' # video height cap, will be less if unavailable in youtube-dl
    URL="$(xclip -selection clipboard -out)"
    restr=()
    YTDLOPTS=()
    eval set -- "$OPTIONS"
    while true; do
        case "$1" in
        -b|--begin)
            shift
            case $1 in
                -1) START=1 ;;
                0*)
                    printf "($1)\n^ unsupported number! exit.\n"
                    exit 1
                    ;;
                ''|*[!0-9]*)
                    printf "($1)\n^ IS NOT A NUMBER OF INT! exit.\n"
                    exit 1
                    ;;
                *) START=$1 ;;
            esac
            ;;
        -e|--end)
            shift
            case $1 in
                -1) END=-1 ;; # get full playlist
                0*)
                    printf "($1)\n^ unsupported number! exit.\n"
                    exit 1
                    ;;
                ''|*[!0-9]*)
                    printf "($1)\n^ IS NOT A NUMBER OF INT! exit.\n"
                    exit 1
                    ;;
                *) END=$1 ;;
            esac
            ;;
        -h|--help)
            echo "$USAGE"
            exit 0
            ;;
        -i|--interactive)
            [ "$ENDOPT" -eq 1 ] && ENDOPT=0 || ENDOPT=1 # toggle behavior of value
            ;;
        -p|--path)
            shift
            OUT="$1"
            ;;
        -r|--restrict)
            restr=( --restrict-filenames )
            ;;
        -q|--quality)
            shift
            QLT="$1"
            ;;
        -y|--ytdl)
            shift
            # convert spaces in argument into individual args if any
            # -> so here we split arg string "$1" to array and arguments
            IFS=' ' read -ra yargs <<< "$1"
            # + to join all previously specified -y options into one array as in EXAMPLES
            YTDLOPTS+=( "${yargs[@]}" )
            ;;
        -u|--url)
            shift
            URL="$1"
            ;;
        --)
            shift
            break
            ;;
        esac
        shift
    done
}

get_opt "$@"

get_index() {
    # get int index value from url and make array option with it
    case "$URL" in
        *"&index="*)
            ndx=$(echo "$URL" | grep -o "&index=[[:digit:]]*" | sed "s/&index=//")
            pindex=( --playlist-items "$ndx" )
        ;;
    esac
}

ytdl_check() {
    # youtube-dl URL verification, verify only first item if many
    get_index
    JSON="$(youtube-dl --dump-json --no-warnings "${pindex[@]}" --playlist-end=1 "$1")"
    return_code=$?
    if [ "$return_code" -ne 0 ]; then
        summary="youtube-dl ERROR CODE[$return_code]:"
        msg="TERMINATED Invalid URL,\nor first element from the URL"
        notify-send -u critical "$summary" "$msg"
        exit $return_code
    else
        RAWOUT=$(echo "$JSON" | ytdl_out_path.sh)
        OUT="$OUT""$RAWOUT"
    fi
}

ytdl() {
    # youtube-dl
    case "$QLT" in
        *"1"*)
            QLT="1080"
        ;;
        *"4"*)
            QLT="480"
        ;;
        *"7"*)
            QLT="720"
        ;;
        *"8"*)
            QLT="1080"
        ;;
    esac >/dev/null
    VIDEO='bestvideo[ext='"$EXT"'][height<=?'"$QLT"']'
    AUDIO='bestaudio[ext='"$EXT"']'
    GLUED="$VIDEO"'+'"$AUDIO"
    FALLBACKVIDEO='bestvideo[height<=?'"$QLT"']'
    FALLBACKAUDIO='bestaudio/best'
    FORMAT="$GLUED"'/'"$FALLBACKVIDEO"'+'"$FALLBACKAUDIO"
    title="$(echo "$JSON" | jq -r ".title")"
    case "$URL" in
        *"playlist?list="*) body="$URL" ;;
        *) body="$title" ;;
    esac
    if [ "$END" = "-1" ]; then
        # last playlist_index num (length)
        lindx="$(echo "$JSON" | jq -r '.playlist_index' | tail -n 1 | sed "s/[ ]*//g")"
        case "$lindx" in
            null|''|*[!0-9]*) lindx=1 ;; # this comes if variable contains non int characters
        esac
    else
        lindx="$END"
    fi
    # show this notification only if script started from terminal,
    # to be sure, that we could check console-title in dunst_download_started.sh script.
    if [ $is_term -eq 1 ]; then
        dunstify -h "string:x-dunst-stack-tag:dp_$fwid" \
            "[DOWNLOAD][VIDEO][STARTED]($fwid){$lindx}:" "\n$body\n"
    fi
    youtube-dl --console-title --ignore-errors --yes-playlist \
        "${pindex[@]}" --playlist-start="$START" --playlist-end="$END" \
        --write-sub --sub-lang en,ru --sub-format "ass/srt/best" --embed-subs \
        --format "$FORMAT" --output "$OUT" "${restr[@]}" "${YTDLOPTS[@]}" "$URL"
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        if [ $is_term -eq 1 ]; then
            dunstify -u normal -h "string:x-dunst-stack-tag:dp_$fwid" \
                "[DOWNLOAD][VIDEO][COMPLETED]($fwid)" "\n$body\n"
        else
            dunstify -u normal -h "string:x-dunst-stack-tag:dp_$fwid" \
                "[DOWNLOAD][VIDEO][FINISHED]" "\n$body\n"
        fi
    else
        dunstify -u critical -h "string:x-dunst-stack-tag:dp_$fwid" \
            "[DOWNLOAD][VIDEO][ERROR]:[$exit_code]" "\n$body\n$URL\n"
        if [ $is_term -eq 1 ]; then
            # here we fake ->
            # to exit out of infinite loop inside dunst_download_started.sh
            xprop -id "$fwid" -set WM_ICON_NAME "DOWNLOAD_COMPLETED"
            sleep 5 # sleep ->
            xdotool set_window --name "$TERMINAL" "$fwid" # set name (because ytdl will leave '...100%...')
            xprop -id "$fwid" -remove WM_ICON_NAME # remove property (as it's default in st)
        fi
        exit "$exit_code"
    fi
}

main() {
    ytdl_check "$URL"
    if [ "$ENDOPT" -eq 1 ]; then
        Q="Download all videos [y/n]? "
        while true; do
            read -p "$Q" -n 1 -r
            echo "" # move to a new line
            case "$REPLY" in
                [Yy]*) END=-1; break;;
                [Nn]*) END=1; break;;
                *) echo "I don't get it.";;
            esac
        done
    fi
    ytdl "$@"
}

main "$@"
