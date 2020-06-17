#!/bin/sh
DEST_PATH="$HOME"'/.config/wallpaper.jpg'
CACHE="$HOME"'/.cache/setbg'
C_XARGS=$(cat "$CACHE" | awk 'NR==1')
C_MARGS=$(cat "$CACHE" | awk 'NR==2')

# read into variable using 'Here Document' code block
read -d '' USAGE <<- EOF
Usage: $(basename $BASH_SOURCE) [OPTION...]
OPTIONS
    -h, --help      Display help
    -i, --image     Provide wallpaper image
    -m, --margs     Use 'magick convert' arguments specified 'inside single quotes'
    -x, --xargs     Set 'xwallpaper' options
    --outint        Set output name by num from '1' to 'N' connected outputs
    --outname       Set output name with grep -i like 'VGA', first found if many
EXAMPLES
    $(basename $BASH_SOURCE) -i image.jpg -x '--maximize' --margs='-colorspace Gray'
    # and to clear margs cache
    $(basename $BASH_SOURCE) -i image.jpg --margs=''
EOF

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
            echo "$USAGE"
            exit 0
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
