#!/bin/sh
# execute command in infinite loop

# read into variable using 'Here Document' code block
read -d '' USAGE <<- EOF
Usage: $(basename $BASH_SOURCE) [OPTION...]
OPTIONS
    -c, --cmd       Command to execute
    -C, --clear     Show only command output
    -h, --help      Display help
    -o, --one       One line mode (replace previous line)
    -s, --sec       Sleep seconds between command execution (default: 5)
EXAMPLE
$(basename $BASH_SOURCE) -c "date +%R"
EOF

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=c:Chos:
    LONG=cmd:,clr,help,one,sec:
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    clr=1
    one=1
    sec=5
    eval set -- "$OPTIONS"
    while true; do
        case "$1" in
        -c|--cmd)
            shift
            cmd="$1"
            ;;
        -C|--clr)
            [[ $clr -eq 1 ]] && clr=0 || clr=1 # toggle behavior of value
            ;;
        -h|--help)
            echo "$USAGE"
            exit 0
            ;;
        -o|--one)
            [[ $one -eq 1 ]] && one=0 || one=1 # toggle behavior of value
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

while true; do
    if [ ! -z "$cmd" ]; then
        OUT=$(${cmd[@]})
    else
        echo "provide command. exit."
        exit 1
    fi
    [[ $clr -eq 1 ]] && tput reset
    if [[ $one -eq 1 ]]; then
        MAXLWIDTH=$(echo "$OUT" | wc --max-line-length)
        CENSOR=$(printf %"$MAXLWIDTH"s | tr " " "X") # print X till max line length
        TRM="\r\033[K"
        printf "%s$TRM%""$MAXLWIDTH"'s' "$CENSOR" "$OUT"
    else
        printf "$OUT\n"
    fi
    sleep $sec
done

