#!/bin/sh
# script for youtube-dl - get from stdin or as $1 arg JSON data from youtube-dl
# and compose output path with optional parts based on their availability in JSON
# SCRIPT OUTPUT EXAMPLES:
# %(uploader)s/%(title)s.%(ext)s
# %(uploader)s/%(playlist_title)s/%(playlist_index)003d. %(title)s.%(ext)s

# read into variable using 'Here Document' code block
read -d '' USAGE <<- EOF
Usage: $(basename $BASH_SOURCE) [OPTION...]
OPTIONS
    -h, --help          Display help
EXAMPLES
# from stdin pipe
    youtube-dl --dump-json --no-warnings --playlist-end=1 "\$URL" | $(basename $BASH_SOURCE)
# from \$1 argument
    $(basename $BASH_SOURCE) "\$JSON_DATA"
EOF

[ "$1" = "-h" ] || [ "$1" = "--help" ] && echo "$USAGE" && exit 0

if [ $# -gt 1 ]; then
    printf "%s\n" "ERROR: too much arguments provided [$#]"
    printf "%s\n" 'DO NOT FORGET to put variable inside " " double quotation marks'
    printf "%s\n\n%s\n" "to provide as single JSON data variable! exit." "$USAGE"
    exit 1
elif test -n "$1"; then
    JSON="$1" # argument
elif test ! -t 0; then
    JSON=$(cat) # /dev/stdin pipe used usually
else
    printf "%s\n\n%s\n" "ERROR: provide JSON data! exit." "$USAGE"
    exit 1
fi

template_dir() { echo "%($1)s/"; }
template_str() { echo "%($1)s"; }
template_num() { echo "%($1)003d. "; }

make_template() {
    # make & echo youtube-dl OUTPUT TEMPLATE based on $1
    arg=$(echo "$1" | sed "s/[/]//") # trim slash if exist
    case "$1" in
        *number*|*playlist_index*) template_num "$arg" ;;
        */*) template_dir "$arg" ;;
        *)   template_str "$arg" ;;
    esac
}

# check if exist & return exit code, do not print stdout/stderr
jcheck() { echo "$JSON" | jq -re ".$1" > /dev/null 2>&1; }

jcheckall() {
    # check multiple args
    args="${*}"
    for arg in $args; do
        trarg=$(echo "$arg" | sed "s/[/]//") # trim slash to check without it
        if jcheck "$trarg"; then
            break # prefer found first -> break out of the loop
        fi
    done
    # found -> for the case when we went through all the arguments and found nothing
    # else  -> don't make template (skip part of output path)
    if jcheck "$trarg"; then
        make_template "$arg" # function decides which template to use
    fi
}

compose_output() {
    # get available parts of output path
    o_top=$(jcheckall 'uploader/' 'playlist_uploader/' 'channel/' 'creator/')
    o_mid=$(jcheckall 'artist/' 'series/' 'playlist_title/')
    o_xtr=$(jcheckall 'album/' 'season_number/' 'season/' 'chapter/')
    o_num=$(jcheckall 'track_number' 'episode_number' 'playlist_index')
    o_bot=$(jcheckall 'track' 'episode' 'title')
    # here we compose our output with optional path parts
    OUT="$o_top""$o_mid""$o_xtr""$o_num""$o_bot"'.%(ext)s'
    echo "$OUT"
}

compose_output
