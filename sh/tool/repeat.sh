#!/bin/sh
# auto repeat command (for example xdotool command)

# read into variable using 'Here Document' code block
read -d '' USAGE <<- EOF
Usage: $(basename $BASH_SOURCE) [OPTION...]
OPTIONS
    -c, --command   Command to execute
    -h, --help      Display help
    -s, --sleep     Seconds to sleep between executions (default 0.5)
EXAMPLE
    $(basename $BASH_SOURCE) -c 'xdotool click 1' -s 1.0
EOF

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=c:hs:
    LONG=command:,help,sleep:
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    sleep_time=0.5
    eval set -- "$OPTIONS"
    while true; do
        case "$1" in
        -c|--command)
            shift
            command_string="$1"
            ;;
        -h|--help)
            echo "$USAGE"
            exit 0
            ;;
        -s|--sleep)
            shift
            sleep_time=$1
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
DIR="$XDG_CACHE_HOME/repeat"
mkdir -p "$DIR"
NAME=$(echo "${command_string// /_}")
CACHE="$DIR/$NAME"'_repeat'

if [ -f "$CACHE" ]; then
    rm -f "$CACHE"
    notify-send -u low -t 1000 "[OFF] REPEAT" "'$command_string'"
    exit 0
else
    echo "$command_string" > "$CACHE"
    notify-send -u low -t 1000 "[ON] REPEAT" "'$command_string'"
fi

while [ -f "$CACHE" ]; do
    command_cached=$(cat "$CACHE")
    sh -c "$command_cached"
    sleep $sleep_time
done

