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

while IFS= read -r file; do
    if [ -e "$file" ]; then
        name="$(basename ${file%.*})" # remove .ext part from file name
        rdir=$(dirname "$file" | cut -d'/' -f2-)
        parents="$DIR_TG"'/'"$rdir"
        mkdir -p "$parents"
        dest="$parents"'/'"${name}.mp4"
        # see also: 'man ffmpeg' and 'x264 --fullhelp' -crf 23 or -crf 28 for more compression
        vf=( -vf scale=-2:360 -pix_fmt yuv420p -max_muxing_queue_size 4096 )
        xf=( -c:v libx264 -profile:v baseline -preset medium -crf 28 )
        af=( -ac 2 -c:a aac -profile:a aac_main )
        ffmpeg -nostdin -nostats -i "$file" "${vf[@]}" "${xf[@]}" "${af[@]}" "$dest" && \
            notify-send -u normal -t 5000 "DONE: Converted for TG." "${name//_/ }" || \
            notify-send -u critical -t 5000 "ERROR: NOT Converted for TG!" "${name//_/ }"
    fi
done <<< "$UNCOMM"

# !!! at the very end of the script !!!
# remember what was done before to not work with same files twice
# find all files starting from current dir and ignore hidden .dot files
find . -type f \( ! -iname ".*" \) > "$HRRCH_OLD"
