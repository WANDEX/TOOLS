#!/bin/sh
DEST_PATH="$HOME"'/.config/wallpaper.jpg'
CACHE="$HOME"'/.cache/setbg'
C_XARGS=$(cat "$CACHE" | awk 'NR==1')
C_MARGS=$(cat "$CACHE" | awk 'NR==2')

usage() {
    # Help message
    printf "Usage: $(basename $BASH_SOURCE) [OPTION...]\n"
    printf "OPTIONS\n"
    printf "\t-h, --help\t\tDisplay help\n"
    printf "\t-i, --image\t\tProvide wallpaper image\n"
    printf "\t-m, --margs\t\tUse \'magick convert\' arguments specified \'inside single quotes\'\n"
    printf "\t-x, --xargs\t\tSet \'xwallpaper\' options\n"
    printf "\t--outint\t\tSet output name by num from '1' to 'N' connected outputs\n"
    printf "\t--outname\t\tSet output name with grep -i like 'VGA', first found if many\n"
    printf "EXAMPLES\n"
    printf "\t$(basename $BASH_SOURCE) -i image.jpg -x '--maximize' --margs='-colorspace Gray'\n"
    printf "\t$(basename $BASH_SOURCE) -i image.jpg --margs='' # to clear margs cache\n"
    exit 0
}

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=hi:m:x:
    LONG=help,image:,margs:,xargs:,outint:,outname:
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    [ -f "$DEST_PATH" ] && image="$DEST_PATH" # get default image if file exist
    xargs_array=(${C_XARGS}); [ -z "$xargs_array" ] && xargs_array=('--zoom') # if C_XARGS empty
    margs_array=(${C_MARGS}) # get 'magick convert' args from cache
    output='all'
    eval set -- "$OPTIONS"
    while true; do
        case "$1" in
        -h|--help)
            usage
            ;;
        -i|--image)
            shift
            image="$1"
            ;;
        -m|--margs)
            shift
            margs_array=($1)
            ;;
        -x|--xargs)
            shift
            xargs_array=($1)
            ;;
        --outint)
            shift
            output=$(xrandr -q | grep -i ' connected' | awk '{print $1}' | awk 'NR=='"$1")
            ;;
        --outname)
            shift
            output=$(xrandr -q | grep -i ' connected' | awk '{print $1}' | grep -i "$1" | awk 'NR==1')
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

if [ ! -z "$margs_array" ]; then
    printf "magick convert (args):\n"
    echo "${margs_array[@]}"
    magick convert "$image" "${margs_array[@]}" "$DEST_PATH"
elif [ ! -z "$image" ]; then
    cp "$image" "$DEST_PATH"
fi
wait
# write to cache
echo "${xargs_array[@]}" > "$CACHE"
echo "${margs_array[@]}" >> "$CACHE"
xwallpaper --output "$output" "${xargs_array[@]}" "$DEST_PATH"
