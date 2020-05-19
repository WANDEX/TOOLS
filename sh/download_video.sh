#!/bin/sh
# download via youtube-dl video playlist or single video

DIR="$HOME"'/Films/'
# default video height cap by the 2nd argument,
# will be less if unavailable in youtube-dl or default
H_CAP='1080'
# youtube-dl --playlist-end > get first N items from playlist
# by the 3rd argument or default N - '-1' to download full playlist
P_CAP='1'
# prefer certain extension over FALLBACK in youtube-dl
EXT='webm'

get_defaults() {
    # use $1 or default (clipboard)
    URL="${1:-$(xclip -selection clipboard -out)}"
    END="${2:-"$P_CAP"}"
    OUT="${3:-"$DIR"}"
    QLT="${4:-"$H_CAP"}"
}

ytdl_check() {
    # youtube-dl URL verification, verify only first item if many
    check="$(youtube-dl --no-warnings --playlist-end=1 --simulate "$1")"
    return_code=$?
    if [ "$return_code" -ne 0 ]; then
        summary="youtube-dl:"
        msg="TERMINATED\nInvalid URL,\nor just the first element from the URL"
        notify-send -t 5000 -u critical "$summary" "$msg"
        exit 1
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
        *)
            QLT="$H_CAP"
        ;;
    esac >/dev/null
    VIDEO='bestvideo[ext='"$EXT"'][height<=?'"$QLT"']'
    AUDIO='bestaudio[ext='"$EXT"']'
    GLUED="$VIDEO"'+'"$AUDIO"
    FALLBACKVIDEO='bestvideo[height<=?'"$QLT"']'
    FALLBACKAUDIO='bestaudio/best'
    FORMAT="$GLUED"'/'"$FALLBACKVIDEO"'+'"$FALLBACKAUDIO"
    OUT+='.yt/%(playlist_title)s/%(playlist_index)003d. %(title)s.%(ext)s'
    time youtube-dl --ignore-errors --yes-playlist --playlist-end="$END" \
        --write-sub --sub-lang en,ru --sub-format "ass/srt/best" --embed-subs \
        --format "$FORMAT" --output "$OUT" "$URL" && \
        notify-send -u normal -t 8000 "COMPLETED:" "Downloading and Converting. [VIDEO]" || \
        notify-send -u critical -t 5000 "ERROR:" "Something gone wrong! [VIDEO]"
}

main() {
    get_defaults "$@"
    ytdl_check "$URL"
    ytdl "$@"
}

main "$@"

