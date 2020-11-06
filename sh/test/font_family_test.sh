#!/bin/sh
# print all available font family variants

red=$'\e[1;31m'; grn=$'\e[1;32m'; yel=$'\e[1;33m'; blu=$'\e[1;34m'; mag=$'\e[1;35m'; cyn=$'\e[1;36m'; end=$'\e[0m'

# read into variable using 'Here Document' code block
read -d '' USAGE <<- EOF
Usage: $(basename $BASH_SOURCE) [OPTION...]
OPTIONS
    -b, --blacklist Comma-separated list of blacklisted font styles
    -f, --font      Get available font family styles for "font family name" or "all"
    -h, --help      Display help
    -s, --styles    Get available font family styles for current \$TERMINAL font
EOF

# read into variable using 'Here Document' code block
# all available font styles presorted
read -d '' STYLES <<- EOF
Thin
Demi
Extralight
ExtraLight
Light
Semi
Book
Medium
Oblique
Extra
Ultra
Semi Expanded
Expanded
Extra Expanded
Ultra Expanded
Semi Condensed
Condensed
Extra Condensed
Ultra Condensed
Medium Italic,Bold
Semibold
SemiBold
Bold
Bold Oblique,Bold
Black
Extrabold
Extra Bold
ExtraBold
Heavy
EOF

get_family_styles() {
    if [[ $1 == all ]]; then
        fc-list | grep -o ":style=.*[ ]" | sed "s/:style=//g; s/[ ]*$//g" | sort -u
    else
        fc-list "$1" | grep -o ":style=.*[ ]" | sed "s/:style=//g; s/[ ]*$//g" | sort -u
    fi
}

font_family=$(font_test.sh --family)
font_typesize=$(font_test.sh --typesize)
font_size=$(font_test.sh --size)
font_style=$(font_test.sh --style)

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=b:f:hs
    LONG=blacklist:,font:,help,style
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    blacklist="Semibold,Bold,Extrabold,Heavy"
    eval set -- "$OPTIONS"
    while true; do
        case "$1" in
        -b|--blacklist)
            shift
            blacklist="$1"
            ;;
        -f|--font)
            shift
            get_family_styles "$1"
            exit 0
            ;;
        -h|--help)
            echo "$USAGE"
            exit 0
            ;;
        -s|--styles)
            get_family_styles "$font_family"
            exit 0
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

tmpd="${TMPDIR:-/tmp/}$(basename $0)" && mkdir -p "$tmpd"
tmpf=$(mktemp "$tmpd/XXXX")

font_family_styles=$(get_family_styles "$font_family")
blacklist=$(echo "$blacklist" | sed s/,/\\n/g)
echo "$font_family_styles" > "$tmpf"
blacklisted=$(echo "$blacklist" | grep -Fixvf - "$tmpf")
echo "$blacklisted" > "$tmpf"
common_styles=$(echo "$STYLES" | grep -Fxf "$tmpf" -) # get common lines in predefined sort order

rm -f "$tmpf" # delete the temporary files
rmdir --ignore-fail-on-non-empty "$tmpd"  # delete temporary dir

while IFS= read -r font_style; do
    FONT="$font_family:""$font_typesize=""$font_size"":style=""$font_style"
    FONTM="${red}$font_family${end}:""$font_typesize=""${cyn}$font_size${end}"":style=${yel}$font_style${end}"
    st -t "ffamily[$font_style]" -f "$FONT" -e any_key.sh font_test.sh --message="$FONTM" &
    sleep 0.1
done <<< "$common_styles"

