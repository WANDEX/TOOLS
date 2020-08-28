#!/bin/sh
# Download in Music dir audio only stream and convert to audio file format

MUSIC="$HOME"'/Music/'

# read into variable using 'Here Document' code block
read -d '' USAGE <<- EOF
Usage: $(basename $BASH_SOURCE) [OPTION...]
OPTIONS
    -e, --end   If url is playlist - how many items to download (by default all:-1)
    -h, --help  Display help
    -p, --path  Destination path where to download
    -u, --url   URL to download
EOF

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=e:hp:u:
    LONG=end:,help,path:,url:
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    URL="$(xclip -selection clipboard -out)"
    END=-1
    OUT="$MUSIC"
    eval set -- "$OPTIONS"
    while true; do
        case "$1" in
        -e|--end)
            shift
            case $1 in
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
        -p|--path)
            shift
            OUT="$1"
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

# substring
case "$URL" in
    *"bandcamp"*)
        OUT+='~bandcamp/%(artist)s/%(playlist)s/%(playlist_index)02d. %(title)s.%(ext)s'
        OPT=( --embed-thumbnail )
    ;;
    *"soundcloud"*"/sets/"*|*"soundcloud"*"/albums"*)
        OUT+='~soundcloud/%(uploader)s/%(playlist)s/%(playlist_index)02d. %(fulltitle)s.%(ext)s'
        OPT=( --embed-thumbnail )
    ;;
    *"soundcloud"*)
        OUT+='~soundcloud/%(uploader)s/%(playlist)s/%(fulltitle)s.%(ext)s'
        OPT=( --embed-thumbnail )
    ;;
    *"youtu"*)
        OUT+='~youtube/%(playlist_title)s/%(playlist_index)02d. %(title)s.%(ext)s'
        OPT=()
    ;;
    *)
        OUT+='~other/%(title)s.%(ext)s'
        OPT=()
    ;;
esac >/dev/null

BEST='bestaudio[asr=48000]'
FALLBACK='bestaudio/best'
FORMAT="$BEST"'/'"$FALLBACK"
notify-send -t 3000 "Downloading..."
time youtube-dl --ignore-errors --yes-playlist --playlist-end="$END" \
    --format "$FORMAT" --output "$OUT" --restrict-filenames \
    --extract-audio --audio-format "mp3" "${OPT[@]}" "$URL" && \
    notify-send -u normal -t 8000 "COMPLETED" "Downloading and Converting." || \
    notify-send -u critical -t 5000 "ERROR" "Something gone wrong!"

