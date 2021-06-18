#!/bin/sh
# terminal font test

# SOURCE GLOBALLY DEFINED TERMINAL COLOR VARIABLES
# shellcheck disable=SC1091
# shellcheck source=$ENVSCR/termcolors
TC="$ENVSCR/termcolors" && [ -r "${TC}" ] && . "${TC}"

# BOLD, ITALIC, UNDERLINE
BLD=$(printf '\e[1m')
ITQ=$(printf '\e[3m')
UND=$(printf '\e[4m')
END=$(printf '\e[0m')

read -r -d '' BOXDC <<- EOF
┌─┬─┐ ╔═╦═╗ ┏━┳━┓        ▏ ▕
├─┼─┤ ╠═╬═╣ ┣━╋━┫ ╭───╮ ╱╲ ╱╲
│ │ │ ║ ║ ║ ┃ ┃ ┃ │ x │ ▏▏╳▕▕
└─┴─┘ ╚═╩═╝ ┗━┻━┛ ╰───╯ ▏───▕
░▒▓█▄▀■ [TERMINAL=$TERMINAL]
EOF

# U+202F   NARROW NO-BREAK SPACE -> ' '
read -r -d '' TEXT <<- EOF
ABCDEFGHIJKLMNOPQRSTUVWXYZ
abcdefghijklmnopqrstuvwxyz
АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ
абвгдеёжзийклмнопрстуфхцчшщъыьэюя
0123456789 ()[]{}<> '' "" \`\`
?!@#$%^&*№ +-=><-_+ \\/| .,:;
> Almost before we knew it,
we had left the ground.
> Алая вспышка осветила
силуэт зазубренного крыла.
EOF

# read into variable using 'Here Document' code block
read -r -d '' USAGE <<- EOF
Usage: $(basename "$0") [OPTION...]
OPTIONS
get one option specific for font of the current \$TERMINAL and exit.
(without option simply print font test)
    -b, --box       Show/Hide box characters
    -f, --family    Get font family
    -h, --help      Display help
    -m, --message   Append custom message to the end of the output
    -S, --style     Get font style
    -s, --size      Get font size
    -t, --typesize  Get font size type - size/pixelsize
EOF

width() { echo "$1" | wc --max-line-length; }
widths() {
    len_a=$(width "$1")
    len_b=$(width "$TEXT")
    len=$(echo "$len_b-$len_a" | bc)
    printf "$1"%"$len"s
}
WR=$(widths "Regular"); WB=$(widths "Bold"); WI=$(widths "Italic")

font_term=$(xrdb -query | grep "$TERMINAL.font:" | awk '{$1="";print $0}' | sed "s/^[ ]*//")
font_multiline=$(echo "$font_term" | sed "s/:/\n/g")

found() { echo "$font_multiline" | grep -q "$1"; }

if  found "family="; then
    family=$(echo "$font_multiline" | sed -n "/family=/s///p")
else
    family=$(echo "$font_multiline" | head -n 1)
fi

if  found "pixelsize="; then
    sn="pixelsize"
    size=$(echo "$font_multiline" | sed -n "/$sn=/s///p")
else
    sn="size"
    size=$(echo "$font_multiline" | sed -n "/$sn=/s///p")
fi

if  found "style="; then
    style=$(echo "$font_multiline" | sed -n "/style=/s///p")
else
    style="Regular"
fi

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=bfhm:Sst
    LONG=box,family,help,message:,style,size,typesize
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    box=0
    eval set -- "$OPTIONS"
    while true; do
        case "$1" in
        -b|--box)
            [ "$box" -eq 1 ] && box=0 || box=1 # toggle behavior of value
            ;;
        -f|--family)
            echo "$family"
            exit 0
            ;;
        -h|--help)
            echo "$USAGE"
            exit 0
            ;;
        -m|--message)
            shift
            message="$1"
            ;;
        -S|--style)
            echo "$style"
            exit 0
            ;;
        -s|--size)
            echo "$size"
            exit 0
            ;;
        -t|--typesize)
            echo "$sn"
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

tmpd="${TMPDIR:-/tmp/}$(basename "$0")" && mkdir -p "$tmpd"
tmpf=$(mktemp "$tmpd/XXXX")
echo "$TEXT" > "$tmpf"
OUT=$(paste -d' ' "$tmpf" "$tmpf" "$tmpf" | awk '
    BEGIN {
        FPAT = "([[:space:]]*[^[:space:]]+)";
        OFS = "";
    }
    {
        $1 = $1;
        $2 = "'"${BLD}"'" $2 "'"${END}"'";
        $3 = "'"${ITQ}"'" $3 "'"${END}"'";
        print
    }
' | column -t -o' ▏' -N "${UND}$WR${END},${BLD}${UND}$WB${END},${ITQ}${UND}$WI${END}") # replace N occurrence
rm -f "$tmpf" # delete the temporary files
rmdir --ignore-fail-on-non-empty "$tmpd"  # delete temporary dir
echo "$OUT"
[ "$box" -eq 1 ] && echo "$BOXDC"
if [ -z "$message" ]; then
    printf "\n%s\n\n" "[xrdb] $TERMINAL.font: ${RED}$family${END} $sn:${CYN}$size${END} style:${YEL}$style${END}"
else
    printf "%s\n" "$message"
fi

