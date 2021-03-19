#!/bin/sh
# dunstify current track & sendmessage love/unlove to scrobbling service & cache
FILE="$HOME/Music/.playlists/.loved_tracks"
DST="string:x-dunst-stack-tag"
TRACK=$(music) # output format is: artist - title
[ -z "$TRACK" ] && exit 0 # if TRACK is empty -> silently exit

case "$1" in
    love)
        emoji="❤"
        operation="add"
        ;;
    unlove)
        emoji="💔"
        operation="remove"
        ;;
    *)
        exit 1 # if first arg is not love/unlove or empty
        ;;
esac

notify() {
    dunstify -t 3000 -u "critical" -h "$DST:mpc_love" -h "$DST:hi" "$1" "$2"
}

write_cache() {
    grep -F -xqs "$TRACK" "$FILE" # return 0 if TRACK exist in cache
    grep_exit_code="$?"
    if [ "$grep_exit_code" -eq 0 ]; then
        # found, TRACK already exist in cache (can be unloved)
        if [ "$operation" = "remove" ]; then
            mpc -q sendmessage mpdas unlove
            sed -i "/$TRACK/d" "$FILE"
            notify "$emoji" "$TRACK"
        else
            # ONLY NOTIFY
            # operation is possibly (add), but
            # TRACK already in cache and (love)
            notify "IMPOSSIBLE OP!" "$emoji"
        fi
    elif [ "$grep_exit_code" -eq 1 ]; then
        # not found, can be added to cache (can be loved)
        if [ "$operation" = "add" ]; then
            mpc -q sendmessage mpdas love
            echo "$TRACK" >> "$FILE"
            notify "$emoji" "$TRACK"
            sort -o "$FILE" "$FILE"
        else
            # ONLY NOTIFY
            # operation is possibly (remove), but
            # there is nothing to remove (unlove)
            notify "IMPOSSIBLE OP!" "$emoji"
        fi
    else
        notify "[mpc_love]" "GREP ERROR: $grep_exit_code"
        exit "$grep_exit_code"
    fi
}

write_cache "$@"
