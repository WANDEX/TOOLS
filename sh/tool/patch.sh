#!/bin/sh
# apply/reverse all patches easily,
# to keep the stacking order of the patches.

red=$'\e[1;31m'; grn=$'\e[1;32m'; yel=$'\e[1;33m'; blu=$'\e[1;34m'; mag=$'\e[1;35m'; cyn=$'\e[1;36m'; end=$'\e[0m'

GITRDIR=$(git rev-parse --show-toplevel)
DIR="$GITRDIR/patch"
if [ -d "$DIR" ]; then
    DIR="$DIR"
elif [ -d "$GITRDIR/patches" ]; then
    DIR="$GITRDIR/patches"
else
    DIR_NOT_FOUND=1
fi

FILE="$DIR/active_patch_list"
if [ -f "$FILE" ]; then
    # remove everything after # character and empty lines with/without spaces
    ORDER=$(cat "$FILE" | sed "s/[[:space:]]*#.*$//g; /^[[:space:]]*$/d")
else
    FILE_NOT_FOUND=1
fi

# read into variable using 'Here Document' code block
read -d '' USAGE <<- EOF
Usage: $(basename $BASH_SOURCE) [OPTION...]
OPTIONS
    -h, --help      Display help
    -l, --list      Print list of patches in default order
    -R, --reverse   Reverse list of patches and apply 'patch --reverse' option:
                    Assume patches were created with old and new files swapped.
    --dry-run       Print the results of applying the patches without actually
                    changing any files.
                    ${red}(each patch file independently, not a cascade of changes)${end}
    --init          Create patch dir with active_patch_list file inside
EOF

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=hlR
    LONG=help,list,reverse,dry-run,init
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    eval set -- "$OPTIONS"
    while true; do
        case "$1" in
        -h|--help)
            echo "$USAGE"
            exit 0
            ;;
        -l|--list)
            echo "patches in default apply patch order:"
            echo "${mag}$ORDER${end}"
            exit 0
            ;;
        -R|--reverse)
            R=(--reverse)
            ORDER=$(echo "$ORDER" | tac)
            ;;
        --dry-run)
            dry=(--dry-run)
            ;;
        --init)
            string="# ignores data after # character (comment string)"
            [ ! -d "$DIR" ] && mkdir -p "$DIR" && echo "created dir : ${yel}$DIR${end}"
            [ ! -f "$FILE" ] && echo "$string" > "$FILE" && echo "created file: ${yel}$FILE${end}" || echo "this file already exist: ${yel}$FILE${end}"
            echo "exit." && exit 0
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

if [ $DIR_NOT_FOUND -eq 1 ]; then
    echo "${red}NOT FOUND ANY PATCH DIR INSIDE CURRENT GIT ROOT DIR:${end}"
    echo "${yel}$GITRDIR${end}"
    echo "Do not forget to ${cyn}cd${end} inside ${cyn}git${end} project, with ${cyn}patch/patches dir${end}. exit."
    exit 1
elif [ $FILE_NOT_FOUND -eq 1 ]; then
    echo "${yel}$FILE${end}"
    echo "${red}FILE DOES NOT EXIST!${end} exit."
    exit 1
fi

if [[ $R ]]; then # if variable defined
    Q="Reverse ALL patches? [Y/n] "
else
    Q="Apply ALL patches? [Y/n] "
fi

read -p "$Q" -n 1 -r
echo "" # move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    # handle exits from shell or function but don't exit interactive shell
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

cd "$GITRDIR" # cd to root git dir
# read line by line
while IFS= read -r line; do
    printf "%s%s\n" "${blu}$(dirname $line)/${end}" \
                    "${cyn}$(basename $line)${end}"
    patch -f "${R[@]}" "${dry[@]}" < "${line[@]}"
done <<< "$ORDER"

echo "${grn}THE END OF THE SCRIPT REACHED${end}"
