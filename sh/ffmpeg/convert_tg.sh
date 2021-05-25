#!/bin/sh
# Convert new files at .mpv_encode/source/ dir to .mp4
# and output with same dir hierarchy to .mpv_encode/tg/ dir
DIR="$HOME"'/Films/.mpv_encode/'
DIR_SRC="$DIR"'source/'
DIR_TG="$DIR"'tg'
DIR_META="$DIR_SRC"'.meta/'
DIR_HRRCH="$DIR_META"'hierarchy/'
HRRCH_NEW="$DIR_HRRCH"'.hierarchy_new'
HRRCH_OLD="$DIR_HRRCH"'.hierarchy_old'

mkdir -p "$DIR_TG" "$DIR_META" "$DIR_HRRCH"
touch "$HRRCH_NEW" "$HRRCH_OLD"
cd "$DIR_SRC"
# find all files relative to current dir and ignore hidden .dot files
find . -type f \( ! -iname ".*" \) > "$HRRCH_NEW"
UNCOMM=$(comm -23 "$HRRCH_NEW" "$HRRCH_OLD") # only new files

convert() {
    # see also: 'man ffmpeg' and 'x264 --fullhelp' -crf 23 or -crf 28 for more compression
    so=( -nostdin -nostats -hide_banner -loglevel warning )
    vf=( -vf scale=-2:360 -pix_fmt yuv420p -max_muxing_queue_size 4096 )
    cf=( -color_primaries 1 -color_trc 1 -colorspace 1 )
    xf=( -c:v libx264 -profile:v baseline -preset medium -crf 28 )
    af=( -ac 2 -c:a aac -profile:a aac_low -ar 44100 )
    ffmpeg "${so[@]}" -i "$file" "${vf[@]}" "${cf[@]}" "${xf[@]}" "${af[@]}" "$dest"
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        notify-send -u normal "[convert_tg] [ENCODEME] Converted" "$name\n($dest)"
    else
        notify-send -u critical "[convert_tg] ERROR:$exit_code NOT Converted" "\n$name"
    fi
}

while IFS= read -r file; do
    if [ -e "$file" ]; then
        name="$(basename ${file%.*})" # remove .ext part from file name
        rdir=$(dirname "$file" | cut -d'/' -f2-)
        parents="$DIR_TG"'/'"$rdir"
        mkdir -p "$parents"
        dest="$parents"'/'"${name}.mp4"
        convert
    fi
done <<< "$UNCOMM"

# !!! at the very end of the script !!!
# remember what was done before to not work with same files twice
# find all files starting from current dir and ignore hidden .dot files
find . -type f \( ! -iname ".*" \) > "$HRRCH_OLD"
