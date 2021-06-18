#!/bin/sh
# download via youtube-dl video playlist or single video

# SOURCE GLOBALLY DEFINED TERMINAL COLOR VARIABLES
# shellcheck disable=SC1091
# shellcheck source=$ENVSCR/termcolors
TC="$ENVSCR/termcolors" && [ -r "${TC}" ] && . "${TC}"

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
read -r -d '' USAGE <<- EOF
Usage: $(basename "$0") [OPTION...]
OPTIONS
    -b, --begin         Download from playlist index (default:1)
    -e, --end           If url is playlist - how many items to download (default:1)
    -f, --file          Read url's from file, and download each specified on it's own line
    -h, --help          Display help
    -i, --interactive   Explicit interactive playlist end mode
    -p, --path          Destination path where to download
    -q, --quality       Quality of video/stream
    -r, --restrict      Restrict filenames to only ASCII characters, and avoid "&" and spaces in filenames
    -u, --url           URL of video/stream
    -y, --ytdl          Any other youtube-dl native options (specify only inside "")
EXAMPLES:
    $(basename "$0") -u "\$URL" -y "--simulate --get-duration" -y "--playlist-items 1-3"
EOF

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=b:e:f:hip:rq:u:y:
    LONG=begin:,end:,file:,help,interactive,path:,restrict,quality:,url:,ytdl:
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
                    printf "(%s)\n^ unsupported number! exit.\n" "$1"
                    exit 1
                    ;;
                ''|*[!0-9]*)
                    printf "(%s)\n^ IS NOT A NUMBER OF INT! exit.\n" "$1"
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
                    printf "(%s)\n^ unsupported number! exit.\n" "$1"
                    exit 1
                    ;;
                ''|*[!0-9]*)
                    printf "(%s)\n^ IS NOT A NUMBER OF INT! exit.\n" "$1"
                    exit 1
                    ;;
                *) END=$1 ;;
            esac
            ;;
        -f|--file)
            shift
            file="$1"
            if [ ! -r "$file" ]; then
                printf "%s\n%s\n" "$file" "^file not found or not readable. exit."
                exit 1
            fi
            # remove everything after # character and empty lines with/without spaces
            URLS=$(sed "s/[[:space:]]*#.*$//g; /^[[:space:]]*$/d" "$file")
            URLL=$(echo "$URLS" | wc -l)
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
    url="$1"
    # get int index value from url and make array option with it
    case "$url" in
        *"&index="*)
            ndx=$(echo "$url" | grep -o "&index=[[:digit:]]*" | sed "s/&index=//")
            pindex=( --playlist-items "$ndx" )
        ;;
    esac
    echo "$ndx"
}

ytdl_check() {
    # youtube-dl URL verification, verify only first item if many
    # get JSON data for url & OUTPATH as global variables
    url="$1"
    get_index "$url" >/dev/null 2>&1 # suppress output & errors
    case "${YTDLOPTS[*]}" in
        *"--no-playlist"*)
            # fix: for case when we specify '-y --no-playlist'
            # without it, we will get many NA in out path
            np=( --no-playlist )
        ;;
    esac
    JSON="$(youtube-dl --dump-json --no-warnings "${pindex[@]}" --playlist-end=1 "${np[@]}" "$url")"
    return_code=$?
    if [ "$return_code" -ne 0 ]; then
        summary="youtube-dl ERROR[$return_code]:"
        msg="TERMINATED Invalid URL,\nor first element from the URL"
        notify-send -u critical "$summary" "$msg"
        exit $return_code
    else
        RAWOUT=$(echo "$JSON" | ytdl_out_path.sh)
        OUTPATH="$OUT""$RAWOUT"
    fi
}

statistic() {
    exit_code="$1"
    # initial values
    [ -z "$ok" ] && ok=0
    [ -z "$err" ] && err=0
    [ -z "$sum" ] && sum=0
    case "$exit_code" in
        0)
            ok=$(echo "$ok+1" | bc)
            printf "${CYN_I}[%s/%s]${END}\n" "$ok" "$URLL"
        ;;
        *)
            err=$(echo "$err+1" | bc)
            printf "${RED_I}[%s(%s)]${END}\n" "ERROR:" "$exit_code"
        ;;
    esac
    sum=$(echo "$ok+$err" | bc)
    if [ "$URLL" -eq "$ok" ]; then
        printf "${CYN_I}[%s]${END} ${CYN}%s${END}\n" "$ok" "ALL OK, FINISHED."
    elif [ "$URLL" -eq "$sum" ]; then
        printf "${MAG}%s ${RED}[%s] ${MAG}%s${END}\n" "FINISHED WITH" "$err" "ERRORS."
    fi
}

ytdl_cmd() {
    url="$1"
    youtube-dl --console-title --ignore-errors --yes-playlist \
        "${pindex[@]}" --playlist-start="$START" --playlist-end="$END" \
        --write-sub --sub-lang en,ru --sub-format "ass/srt/best" --embed-subs \
        --format "$FORMAT" --output "$OUTPATH" "${restr[@]}" "${YTDLOPTS[@]}" "$url"
    exit_code=$?
    [ "$URLL" ] && statistic "$exit_code"
}

add_index() {
    # remove old & add new index to filename, then output new path
    _index="$1"
    _path=$(dirname "$OUTPATH")
    _base=$(basename "$OUTPATH" | sed "s/^[[:digit:]]\+\. //") # remove old index
    _out="$_path/$_index$_base"
    echo "$_out"
}

loop_over_urls() {
    # read line by line
    while IFS= read -r url; do
        ytdl_check "$url"
        case "$url" in
            *"&index="*)
                # if url contains explicit index, use it as filename prefix
                index=$(get_index "$url") # get_index out of url parameters
                findex=$(printf "%.3d%s" "$index" ". ") # make index of format
                OUTPATH=$(add_index "$findex")
            ;;
        esac
        printf "\n${CYN}> %s${END}\n" "$url"
        ytdl_cmd "$url"
    done <<< "$URLS"
}

ytdl_download() {
    url="$1"
    if [ -n "$URLS" ]; then
        loop_over_urls
    else
        ytdl_check "$url"
        ytdl_cmd "$url"
    fi
}

ytdl() {
    # youtube-dl
    url="$1"
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
    case "$url" in
        *"playlist?list="*) body="$url" ;;
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
    ytdl_download "$url"
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
            "[DOWNLOAD][VIDEO][ERROR]:[$exit_code]" "\n$body\n$url\n"
        if [ $is_term -eq 1 ]; then
            # here we fake ->
            # to exit out of infinite loop inside dunst_download_started.sh
            xprop -id "$fwid" -set WM_ICON_NAME "DOWNLOAD_COMPLETED"
            sleep 5 # sleep ->
            xdotool set_window --name "$TERMINAL" "$fwid" # set name (because ytdl will leave '...100%...')
            xprop -id "$fwid" -remove WM_ICON_NAME # remove property (as it's default in st)
        fi
        exit $exit_code
    fi
}

main() {
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
    ytdl "$URL"
}

main "$@"
