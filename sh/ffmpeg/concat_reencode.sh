#!/bin/sh
# glue together video files with re-encoding where each file provided as next argument

DIR="rg/"
mkdir -p "$DIR"

name='rg_'"$(basename "$1")" # .ext unchanged
dest="${DIR}${name}"
fps=30

# initial values, do not touch!
iarr=()
filter=""
i=0

# for each file in args:
# add to array -i file
# compose filter_complex string variable
# count total files
for f in "$@"; do
    iarr=( "${iarr[@]}" -i "${f}" )
    filter="${filter}[$i:v] [$i:a] "
    i="$(echo "$i+1" | bc)"
done

# concat="concat=n=${n}:v=1:a=1 [v] [a]"
concat="concat=n=${i}:v=1:a=1:unsafe=1 [v] [a]"
fc="${filter}${concat}"

# defaults:
so=( -nostdin -nostats -hide_banner -loglevel warning )
vf=( -max_muxing_queue_size 4096 )
# vf=( -vf "scale=-2:360,pad=ih*16/9:ih:(ow-iw)/2:(oh-ih)/2" -pix_fmt yuv420p -max_muxing_queue_size 4096 )
cf=( -color_primaries 1 -color_trc 1 -colorspace 1 )
xf=( -c:v libx264 -profile:v baseline -preset medium -crf 28 )
af=( -ac 2 -c:a aac -profile:a aac_low -ar 44100 )

cmd=( ffmpeg -y "${so[@]}" "${iarr[@]}" \
    "${vf[@]}" "${cf[@]}" "${xf[@]}" "${af[@]}" \
    -filter_complex "$fc" -map "[v]" -map "[a]" \
    -fpsmax "$fps" "$dest" )

echo "${cmd[@]}" # print full command text
"${cmd[@]}" # execute
printf "\n" # insert new line
