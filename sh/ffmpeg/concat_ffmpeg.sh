#!/bin/sh
# glue together video files where each file provided as next argument
FILE_LIST="$XDG_CACHE_HOME/ffmpeg_concat"
FILE_NAME='glued_'"$(basename $1)"

# print each arument on new line
for ARG in "$@"; do
    #echo $ARG >> "$FILE_LIST"
    echo "file '$ARG'" >> "$FILE_LIST"
done

ffmpeg -nostdin -f concat -safe 0 -i "$FILE_LIST" -c copy "$FILE_NAME"

#ffmpeg -i input1.mp4 -i input2.webm -i input3.mov \
#ffmpeg -nostdin -f concat -safe 0 -i "$FILE_LIST" \
#-filter_complex "[0:v:0][0:a:0][1:v:0][1:a:0][2:v:0][2:a:0]concat=n=3:v=1:a=1[outv][outa]" \
#-map "[outv]" -map "[outa]" "$FILE_NAME"

#sleep 5
rm -f "$FILE_LIST"
