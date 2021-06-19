#!/bin/sh
# glue together video files where each file provided as next argument
FILE_LIST="$XDG_CACHE_HOME/ffmpeg_concat"
FILE_NAME='glued_'"$(basename "$1")"

# print each arument on new line
for ARG in "$@"; do
    echo "file '$ARG'" >> "$FILE_LIST"
done

ffmpeg -nostdin -f concat -safe 0 -i "$FILE_LIST" -c copy "$FILE_NAME"

rm -f "$FILE_LIST"
