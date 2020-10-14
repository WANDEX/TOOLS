#!/bin/sh
# apply/reverse all patches easily,
# to keep the stacking order of the patches.

red=$'\e[1;31m'; grn=$'\e[1;32m'; yel=$'\e[1;33m'; blu=$'\e[1;34m'; mag=$'\e[1;35m'; cyn=$'\e[1;36m'; end=$'\e[0m'

# read into variable using 'Here Document' code block
read -d '' USAGE <<- EOF
Usage: $(basename $BASH_SOURCE) [OPTION...]
OPTIONS
    -h, --help      Display help
    -l, --list      Print list of patches in default order
    -R, --reverse   Reverse list of patches and apply 'patch --reverse' option:
                    Assume patches were created with old and new files swapped.
    -s, --solo      Single shot mode for one of the patches from --list,
                    '-s N', by default it is assumed that this patch is not applied!
                    first usage - apply patch, second - reverse patch, and so forth.
    --dry-run       Print the results of applying the patches without actually
                    changing any files.
                    ${red}(each patch file independently, not a cascade of changes)${end}
    --init          Create patch dir with active_patch_list file inside
EOF

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
    SEP='| '
    ORDER=$(echo "$ORDER" | nl -w2 -s"$SEP")
    N_MAX=$(echo "$ORDER" | wc -l)
else
    FILE_NOT_FOUND=1
fi

print_colored() {
    if [[ $1 == all ]]; then
        arg="$ORDER"
        msg="patches in default apply patch order:\n"
        tmpd="${TMPDIR:-/tmp/}$(basename $0)" && mkdir -p "$tmpd"
        tmpf_num=$(mktemp "$tmpd/XXXX")
        tmpf_dir=$(mktemp "$tmpd/XXXX")
        tmpf_bsn=$(mktemp "$tmpd/XXXX")
        echo "$arg" | awk '{print $1}' > "$tmpf_num"
        echo "$arg" | sed "s/^.*[ ]//g; s/[^/]*$//g" > "$tmpf_dir"
        echo "$arg" | sed "s/^.*[/]//g" > "$tmpf_bsn"
        # colorize columns
        OUT=$(paste -d'\t' "$tmpf_num" "$tmpf_dir" "$tmpf_bsn" | awk '
            BEGIN {
                FPAT = "([[:space:]]*[^[:space:]]+)";
                OFS = "";
            }
            {
                $1 = "'${mag}'" $1 "'${end}'";
                $2 = "'${blu}'" $2 "'${end}'";
                $3 = "'${cyn}'" $3 "'${end}'";
                print
            }
        ' | column -t)
        rm -f "$tmpf_num" "$tmpf_dir" "$tmpf_bsn" # delete the temporary files
        rmdir --ignore-fail-on-non-empty "$tmpd"  # delete temporary dir
    else
        arg="$1"
        file="$2"
        if [ -z "$file" ]; then
            echo "ERROR: file variable is empty in function call. exit"
            exit 1
        fi
        msg=""
        num=$(echo $arg | awk '{print $1}')
        dir=$(dirname $file)
        bsn=$(basename $file)
        OUT=$(printf "%s  %s%s" "${mag}$num${end}" \
                                "${blu}$dir/${end}" \
                                "${cyn}$bsn${end}")
    fi
    printf "$msg""$OUT""\n"
}

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=hlRs:
    LONG=help,list,reverse,solo:,dry-run,init
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    debug=0
    eval set -- "$OPTIONS"
    while true; do
        case "$1" in
        -h|--help)
            echo "$USAGE"
            exit 0
            ;;
        -l|--list)
            print_colored all
            exit 0
            ;;
        -R|--reverse)
            R=(--reverse)
            ORDER=$(echo "$ORDER" | tac)
            ;;
        -s|--solo)
            shift
            case $1 in
                0*)
                    printf "$1\n^ unsupported number! exit.\n"
                    exit 1
                    ;;
                ''|*[!0-9]*)
                    printf "$1\n^ IS NOT A NUMBER OF INT! exit.\n"
                    exit 1
                    ;;
                *) solo_n=$1 ;;
            esac
            if [[ $solo_n -gt $N_MAX ]]; then
                echo "[$solo_n] - there is no such list item related to this number. exit"
                exit 1
            fi
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

non_existence_msg() {
    if [[ $DIR_NOT_FOUND -eq 1 ]]; then
        echo "${red}NOT FOUND ANY PATCH DIR INSIDE CURRENT GIT ROOT DIR:${end}"
        echo "${yel}$GITRDIR${end}"
        echo "Do not forget to ${cyn}cd${end} inside ${cyn}git${end} project, with ${cyn}patch/patches dir${end}. exit."
        exit 1
    elif [[ $FILE_NOT_FOUND -eq 1 ]]; then
        echo "${yel}$FILE${end}"
        echo "${red}FILE DOES NOT EXIST!${end} exit."
        exit 1
    fi
}

validate() {
    # if variable defined
    [[ $R ]] && RA="Reverse" || RA="Apply"
    [[ $solo_n ]] && SA="ONLY this patch?" || SA="ALL patches?"
    Q="$RA $SA [y/n] "
    read -p "$Q" -n 1 -r
    echo "" # move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        # handle exits from shell or function but don't exit interactive shell
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
    fi
}

cmmnd() {
    arg=$1
    cd "$GITRDIR" # cd to root git dir
    # replace all digit characters with nothing and check for length
    if [[ -n ${arg//[0-9]/} ]]; then # True if the length is non-zero.
        # arg is string
        GREP=$(echo "$ORDER" | grep "$arg")
        ET="string"
    else
        # arg is number
        GREP=$(echo "$ORDER" | grep $arg"$SEP")
        ET="number"
        #if
            #R=(--reverse)
        #else
            #R=()
        #fi
    fi
    # discard first column & trim leading spaces
    file=$(echo "$GREP" | awk '{$1="";print $0}' | sed "s/^[ ]*//")
    print_colored "$GREP" "$file"
    [[ $debug -eq 1 ]] && printf "${mag}file found by $ET:${end}${yel}$file${end}\n"
    patch -f "${R[@]}" "${dry[@]}" < "$file"
}

main() {
    get_opt "$@"
    non_existence_msg
    validate
    if [[ $solo_n ]]; then # if variable defined
        cmmnd $solo_n
    else
        # read line by line
        while IFS= read -r line; do
            cmmnd "$line"
        done <<< "$ORDER"
        echo "${grn}END OF PATCH LIST REACHED${end}"
    fi
}

main "$@"
