#!/bin/sh
# convert all video files where each file provided as next argument

# if at least 2 arguments given create & output into sub dir
if [ -n "$2" ]; then
    DIR="converted/"
    mkdir -p "$DIR"
fi

convert() {
    file="$1"
    name="$(basename "$file" | cut -d'.' -f1)" # remove .ext part from file name
    dest="${DIR}c_${name}.mp4"
    # see also: 'man ffmpeg' and 'x264 --fullhelp' -crf 23 or -crf 28 for more compression
    so=( -nostdin -nostats -hide_banner -loglevel warning )

    # without 16:9 pad
    # vf=( -vf scale=-2:360 -pix_fmt yuv420p -max_muxing_queue_size 4096 )
    # with 16:9 pad
    vf=( -vf "scale=-2:360,pad=ih*16/9:ih:(ow-iw)/2:(oh-ih)/2" -pix_fmt yuv420p -max_muxing_queue_size 4096 )

    cf=( -color_primaries 1 -color_trc 1 -colorspace 1 )
    xf=( -c:v libx264 -profile:v baseline -preset medium -crf 28 )
    af=( -ac 2 -c:a aac -profile:a aac_low -ar 44100 )
    ffmpeg -y "${so[@]}" -i "$file" "${vf[@]}" "${cf[@]}" "${xf[@]}" "${af[@]}" "$dest"
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        notify-send -u normal "[convert] Converted" "$name\n($dest)"
    else
        notify-send -u critical "[convert] ERROR:$exit_code NOT Converted" "\n$name"
    fi
}

# for each file in args
for f in "$@"; do
    convert "$f"
done
