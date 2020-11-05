#!/bin/sh
# terminal font test

red=$'\e[1;31m'; grn=$'\e[1;32m'; yel=$'\e[1;33m'; blu=$'\e[1;34m'; mag=$'\e[1;35m'; cyn=$'\e[1;36m'; end=$'\e[0m'
def_b=$'\e[0;1m'; def_i=$'\e[0;3m'
def_B=$'\e[4;1m'; def_I=$'\e[4;3m'; def_R=$'\e[4m'

read -d '' BOXDC <<- EOF
┌─┬─┐ ╔═╦═╗ ┏━┳━┓        ▏ ▕
├─┼─┤ ╠═╬═╣ ┣━╋━┫ ╭───╮ ╱╲ ╱╲
│ │ │ ║ ║ ║ ┃ ┃ ┃ │ x │ ▏▏╳▕▕
└─┴─┘ ╚═╩═╝ ┗━┻━┛ ╰───╯ ▏───▕
░▒▓█▄▀■ [TERMINAL=$TERMINAL]
EOF

# U+202F   NARROW NO-BREAK SPACE -> ' '
read -d '' TEXT <<- EOF
ABCDEFGHIJKLMNOPQRSTUVWXYZ
abcdefghijklmnopqrstuvwxyz
АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ
абвгдеёжзийклмнопрстуфхцчшщъыьэюя
0123456789 ()[]{}<> '' "" \`\`
?!@#$%^&*№ +-=><-_+ \\\/| .,:;
> Almost before we knew it,
we had left the ground.
> Алая вспышка осветила
силуэт зазубренного крыла.
EOF

# read into variable using 'Here Document' code block
read -d '' USAGE <<- EOF
Usage: $(basename $BASH_SOURCE) [OPTION...]
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
font_multiline=$(echo $font_term | sed "s/:/\n/g")

if $(echo "$font_multiline" | grep -q "family="); then
    family=$(echo "$font_multiline" | sed -n "/family=/s///p")
else
    family=$(echo "$font_multiline" | head -n 1)
fi
if $(echo "$font_multiline" | grep -q "pixelsize="); then
    sn="pixelsize"
    size=$(echo "$font_multiline" | sed -n "/$sn=/s///p")
else
    sn="size"
    size=$(echo "$font_multiline" | sed -n "/$sn=/s///p")
fi
if $(echo "$font_multiline" | grep -q "style="); then
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
            [[ $box -eq 1 ]] && box=0 || box=1 # toggle behavior of value
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

tmpd="${TMPDIR:-/tmp/}$(basename $0)" && mkdir -p "$tmpd"
tmpf=$(mktemp "$tmpd/XXXX")
echo "$TEXT" > "$tmpf"
OUT=$(paste -d' ' "$tmpf" "$tmpf" "$tmpf" | awk '
    BEGIN {
        FPAT = "([[:space:]]*[^[:space:]]+)";
        OFS = "";
    }
    {
        $1 = $1;
        $2 = "'${def_b}'" $2 "'${end}'";
        $3 = "'${def_i}'" $3 "'${end}'";
        print
    }
' | column -t -o' ▏' -N "${def_R}$WR${end},${def_B}$WB${end},${def_I}$WI${end}") # replace N occurrence
rm -f "$tmpf" # delete the temporary files
rmdir --ignore-fail-on-non-empty "$tmpd"  # delete temporary dir
echo "$OUT"
[[ $box -eq 1 ]] && echo "$BOXDC"
if [ -z "$message" ]; then
    printf "\n[xrdb] $TERMINAL.font: ${red}$family${end} $sn:${cyn}$size${end} style:${yel}$style${end}\n\n"
else
    printf "\n$message\n\n"
fi

