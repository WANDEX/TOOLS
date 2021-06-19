#!/bin/sh
# generate video file with text in the center of the screen

# read into variable using 'Here Document' code block
read -r -d '' USAGE <<- EOF
Usage: $(basename "$0") [OPTION...]
OPTIONS
    -b, --background    Background color (default black)
    -d, --duration      Duration of the output video (default 1.0)
    -f, --font          Font to use
    -g, --gte           Delay the display of text in seconds (default 0)
    -h, --help          Display help
    -i, --input         Use input video as background
    -n, --name          Name of the output video
    -r, --resolution    Video resolution
    -s, --size          Font size
    -t, --text          Draw text on the screen
    --bordercolor       Font border color (default black)
    --borderwidth       Font border width (default 3)
    --fontcolor         Font foreground color (default white)
EXAMPLES:
    $(basename "$0") -t 'Multiline \\
    string \\
    example'
EOF

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=b:d:f:g:hi:n:r:s:t:
    LONG=background:,duration:,font:,gte:,help,input:,name:,resolution:,size:,text:,bordercolor:,borderwidth:,fontcolor:
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    background="black"
    duration=3.0
    font_path="$HOME/.local/share/fonts/roboto/Roboto_Slab/RobotoSlab-Light.ttf"
    gte=0
    name="output"
    resolution="1280x720"
    size=48
    text="Sample Text"
    fontcolor="white"
    bordercolor="black"
    borderwidth=3
    eval set -- "$OPTIONS"
    while true; do
        case "$1" in
        -b|--background)
            shift
            background="$1"
            ;;
        -d|--duration)
            shift
            duration=$1
            ;;
        -f|--font)
            shift
            font_path="$1"
            ;;
        -g|--gte)
            shift
            gte=$1
            ;;
        -h|--help)
            echo "$USAGE"
            exit 0
            ;;
        -i|--input)
            shift
            input="$1"
            ;;
        -n|--name)
            shift
            name="$1"
            ;;
        -r|--resolution)
            shift
            resolution="$1"
            ;;
        -s|--size)
            shift
            size=$1
            ;;
        -t|--text)
            shift
            text="$1"
            ;;
        --bordercolor)
            shift
            bordercolor="$1"
            ;;
        --borderwidth)
            shift
            borderwidth=$1
            ;;
        --fontcolor)
            shift
            fontcolor="$1"
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
common=(
    "drawtext=fontfile=$font_path:\
    enable='gte(t,$gte)':\
    fontsize=$size:\
    fontcolor=$fontcolor:\
    bordercolor=$bordercolor:\
    borderw=$borderwidth:\
    x=(w-text_w)/2:\
    y=(h-text_h)/2:\
    text='$text'"\
    "${name}.mp4"
)

#if input file specified
if [ -n "$input" ]; then
    ffmpeg -y -i "$input" \
    -vf "${common[@]}"
else
    # line with 'aevalsrc=0' adds silent audio -> to be able to concat with other video files
    ffmpeg -y -f lavfi -i color=c="$background":s="$resolution":d="$duration" \
    -f lavfi -i aevalsrc=0 -map 0 -map 1 -shortest \
    -vf "${common[@]}"
fi

