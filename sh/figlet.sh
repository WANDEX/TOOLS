#!/bin/sh
# don't forget to use double quotes "$1" "$2 ..." for multiple options
TEXT="${1:-$(whoami)}"
OPTIONS_ARRAY=($2)
if [ -z "$2" ]; then
    figlet -f lean -C upper "$TEXT" | tr ' _/' '/_'
else
    figlet -f "${OPTIONS_ARRAY[@]}" "$TEXT"
fi
