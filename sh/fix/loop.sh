#!/bin/sh
# execute command in infinite loop

# read into variable using 'Here Document' code block
read -r -d '' USAGE <<- EOF
Usage: $(basename "$0") [OPTION...]
OPTIONS
    -c, --cmd           Command to execute
    -C, --clear         Toggle showing only command output
    -h, --help          Display help
    -H, --hidecursor    Toggle Hiding of terminal cursor before execution of a command
    -o, --one           Toggle One line mode (replace previous line)
    -s, --sec           Sleep seconds between command execution (default: 5)
EXAMPLE
$(basename "$0") -c "date +%R"
EOF

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=c:ChHos:
    LONG=cmd:,clr,help,hidecursor,one,sec:
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    clr=1
    one=1
    sec=5
    hic=1
    eval set -- "$OPTIONS"
    while true; do
        case "$1" in
        -c|--cmd)
            shift
            cmd="$1"
            ;;
        -C|--clr)
            [ "$clr" -eq 1 ] && clr=0 || clr=1 # toggle behavior of value
            ;;
        -h|--help)
            echo "$USAGE"
            exit 0
            ;;
        -H|--hidecursor)
            [ "$hic" -eq 1 ] && hic=0 || hic=1 # toggle behavior of value
            ;;
        -o|--one)
            [ "$one" -eq 1 ] && one=0 || one=1 # toggle behavior of value
            ;;
        -s|--sec)
            shift
            sec="$1"
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

[ "$hic" -eq 1 ] && tput civis # hide cursor

while true; do
    if [ -n "$cmd" ]; then
        OUT=$("${cmd[@]}")
    else
        echo "provide command. exit."
        exit 1
    fi
    [ "$clr" -eq 1 ] && tput reset
    if [ "$one" -eq 1 ]; then
        MAXLWIDTH=$(echo "$OUT" | wc --max-line-length)
        CENSOR=$(printf %"$MAXLWIDTH"s | tr " " "X") # print X till max line length
        TRM="\r\033[K"
        printf "%s$TRM%""$MAXLWIDTH"'s' "$CENSOR" "$OUT"
    else
        printf "%s\n" "$OUT"
    fi
    sleep "$sec"
done

[ "$hic" -eq 1 ] && tput cnorm # restore cursor
