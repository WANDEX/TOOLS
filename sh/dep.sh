#!/bin/sh
# check which dependency libs are not installed for given binary as first parameter.

# SOURCE GLOBALLY DEFINED TERMINAL COLOR VARIABLES
# shellcheck disable=SC1091
# shellcheck source=$ENVSCR/termcolors
TC="$ENVSCR/termcolors" && [ -r "${TC}" ] && . "${TC}"

# list libs required by provided binary
LIBS=$(objdump -p "$1" | grep NEEDED | awk '{ $1=""; print substr($0,2) }')

while IFS= read -r line; do
    ## Exit codes: 0 = match found; 1 = no match found; 2 = error;
    pacman -F "$line" | grep -q installed
    case "$?" in
        0) statusMsg="${CYN}[installed]${END}...";;
        1) statusMsg="${RED}[REQUIRED]${END}....";;
        2) statusMsg="${RED}[ERROR]${END}.......";;
        *) statusMsg="${RED}[??? WTF ???]${END}." && exit 1 ;;
    esac >/dev/null
    printf "%s %s\n" "$statusMsg" "$line"
done <<< "$LIBS"

printf "\nTo find out in which Repo & Package lib exists:\n"
printf "%s\n" "${CYN}pacman -F${END} ..."
