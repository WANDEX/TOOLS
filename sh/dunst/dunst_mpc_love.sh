#!/bin/sh
# dunstify current track & sendmessage love/unlove to scrobbling service
DST="string:x-dunst-stack-tag"
track=$(music) # artist - title

case "$1" in
    love)
        mpc -q sendmessage mpdas love
        emoji="❤"
        ;;
    unlove)
        mpc -q sendmessage mpdas unlove
        emoji="💔"
        ;;
    *)
        exit 1
        ;;
esac

dunstify -t 3000 -u "critical" -h "$DST:mpc_love" -h "$DST:hi" "$emoji" "$track"
