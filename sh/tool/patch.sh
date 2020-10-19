#!/bin/sh
# apply/reverse all patches easily,
# to keep the stacking order of the patches.

red=$'\e[1;31m'; grn=$'\e[1;32m'; yel=$'\e[1;33m'; blu=$'\e[1;34m'; mag=$'\e[1;35m'; cyn=$'\e[1;36m'; end=$'\e[0m'
SEP='|'; NLS=')'

# read into variable using 'Here Document' code block
read -d '' USAGE <<- EOF
Usage: $(basename $BASH_SOURCE) [OPTION...]
OPTIONS
    -a, --add       Add patch to the end of active_patch_list file
    -h, --help      Display help
    -l, --list      Print list of patches in default order
    -m, --mark      Select patches found by mark and apply/reject all
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

check_existance() {
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
        ORDER=$(echo "$ORDER" | nl -w2 -n"rn" -s"$NLS")
        N_MAX=$(echo "$ORDER" | wc -l)
    else
        FILE_NOT_FOUND=1
    fi
}

print_colored() {
    sed_num="s/.$//"
    sed_mrk="s/[[:digit:]]*$NLS$SEP\(.\).*$/\1/p"
    if [[ $1 == all ]]; then
        arg="$ORDER"
        msg="patch order:\n"
        tmpd="${TMPDIR:-/tmp/}$(basename $0)" && mkdir -p "$tmpd"
        tmpf_num=$(mktemp "$tmpd/XXXX")
        tmpf_mrk=$(mktemp "$tmpd/XXXX")
        tmpf_dir=$(mktemp "$tmpd/XXXX")
        tmpf_bsn=$(mktemp "$tmpd/XXXX")
        echo "$arg" | awk '{print $1}' | sed "$sed_num" > "$tmpf_num"
        echo "$arg" | awk '{print $1}' | sed -n "$sed_mrk" > "$tmpf_mrk"
        echo "$arg" | sed "s/^.*[ ]//g; s/[^/]*$//g" > "$tmpf_dir"
        echo "$arg" | sed "s/^.*[/]//g" > "$tmpf_bsn"
        # colorize columns
        OUT=$(paste -d' ' "$tmpf_num" "$tmpf_mrk" "$tmpf_dir" "$tmpf_bsn" | awk '
            BEGIN {
                FPAT = "([[:space:]]*[^[:space:]]+)";
                OFS = "";
            }
            {
                $1 = "'${mag}'" $1 "'${end}'";
                $2 = "'${red}'" $2 "'${end}'";
                $3 = "'${blu}'" $3 "'${end}'";
                $4 = "'${cyn}'" $4 "'${end}'";
                print
            }
        ' | sed 's/[ ]//3; s/[ ]//1' | column -t -o' ') # replace N occurrence
        rm -f "$tmpf_num" "$tmpf_mrk" "$tmpf_dir" "$tmpf_bsn" # delete the temporary files
        rmdir --ignore-fail-on-non-empty "$tmpd"  # delete temporary dir
    else
        file="$1"
        if [ -z "$file" ]; then
            echo "ERROR: file variable is empty in function call. exit"
            exit 1
        fi
        msg=""
        num=$(echo "$ORDER" | grep "$file" | awk '{print $1}' | sed "$sed_num")
        mrk=$(echo "$ORDER" | grep "$file" | awk '{print $1}' | sed -n "$sed_mrk")
        dir=$(dirname $file)
        bsn=$(basename $file)
        OUT=$(printf "%s%s %s%s" "${mag}$num${end}" \
                                "${red}$mrk${end}" \
                                "${blu}$dir/${end}" \
                                "${cyn}$bsn${end}")
    fi
    printf "$msg""$OUT""\n"
}

add_patch() {
    patch_file_path="$1"
    SPACES='  '
    printf "$SEP"N"$SPACES$patch_file_path\n" >> "$FILE"
    echo "${yel}$patch_file_path${end}"
    echo "patch added to the end of the active_patch_list. exit"
    exit 0
}

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=a:hlm:Rs:
    LONG=add:,help,list,mark:,reverse,solo:,dry-run,init
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    debug=0
    eval set -- "$OPTIONS"
    while true; do
        case "$1" in
        -a|--add)
            shift
            add_patch "$1"
            ;;
        -h|--help)
            echo "$USAGE"
            exit 0
            ;;
        -l|--list)
            print_colored all
            exit 0
            ;;
        -m|--mark)
            shift
            ORDER=$(echo "$ORDER" | grep -i "$NLS$SEP$1")
            print_colored all
            printf "${mag}[${end}${red}$1${mag}]${end} ^ ABOVE PATCHES SELECTED BY MARK\n\n"
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

reverse_order() {
    Q="Reverse Order of Patches? ${yel}(from last to first)${end} [y/n] "
    while true; do
        read -p "$Q" -n 1 -r
        case "$REPLY" in
            [Yy]*) ORDER=$(echo "$ORDER" | tac); break;;
            [Nn]*) break;;
            *) echo "${red}I don't get it.${end}";;
        esac
    done
    printf "\nFollowing order will be used, "
    print_colored all
    echo ""
}

validate() {
    # if variable defined
    if [[ $R ]]; then
        RA="Reverse"
        M="R"
    else
        RA="Apply"
        M="A"
    fi
    [[ $solo_n ]] && SA="ONLY this patch?" || SA="ALL patches?"
    Q="$RA $SA [y/n] "
    if [[ $INSIDE_READ_LINE_LOOP -eq 1 ]]; then
        read -p "$Q" -n 1 -r <&$IN
    else
        read -p "$Q" -n 1 -r
    fi
    echo "" # move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        # handle exits from shell or function but don't exit interactive shell
        [[ "$0" = "$BASH_SOURCE" ]] && exit 0 || return 1
    fi
}

get_line_num() {
    pattern="$1"
    lnum=$(sed -n '\|'"$pattern"'|=' "$FILE") # get line number with pattern
    echo "$lnum"
}

get_patch_mark() {
    patch_file_path="$1"
    lnum=$(get_line_num "$patch_file_path")
    mark=$(sed -n $lnum's/^'"$SEP"'\(.\).*$/\1/p' "$FILE")
    echo "$mark"
}

add_mark() {
    patch_file_path="$1"
    mark="$2"
    lnum=$(get_line_num "$patch_file_path")
    if [[ "$mark" == F ]]; then
        echo "${blu}Patch contained${end} ${red}FAILED Hunk${end}"
        echo "${blu}and marked as:${end}${red}F${end}"
    fi
    [[ ! $dry ]] && sed -i $lnum"s/^$SEP./$SEP$mark/" "$FILE" &&
    [[ $debug -eq 1 ]] && echo "mark:${red}$mark${end} SET!"
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
        GREP=$(echo "$ORDER" | grep $arg"$NLS$SEP")
        ET="number"
    fi
    # discard first column & trim leading spaces
    file=$(echo "$GREP" | awk '{$1="";print $0}' | sed "s/^[ ]*//")
    if [[ ! $R ]]; then # if -R option not explicitly specified
        # automatic toggle behavior of patch -R (reverse/apply) option
        case "$(get_patch_mark "$file")" in
            A) R=(--reverse);;
            N) R=();;
            R) R=();;
            F)
                echo "Previously this patch introduced ${red}FAILED Hunks!${end}"
                make clean && echo "${cyn}make clean [finished]${end}"
                print_colored "$file"
                while true; do
                    if [[ $INSIDE_READ_LINE_LOOP -eq 1 ]]; then
                        read -p "Apply/Reverse this patch? [a/r] " -n 1 -r <&$IN
                    else
                        read -p "Apply/Reverse this patch? [a/r] " -n 1 -r
                    fi
                    echo "" # move to a new line
                    case "$REPLY" in
                        [Aa]*) R=(); break;;
                        [Rr]*) R=(--reverse); break;;
                        *) echo "${red}I don't get it.${end}";;
                    esac
                done
                ;;
            *)
                echo "${red}ERROR: patch_mark for this file not found!${end}"
                print_colored "$file"
                echo "check your active_patch_list file. exit."
                exit 1
                ;;
        esac
    fi
    print_colored "$file"
    [[ $debug -eq 1 ]] && echo "${mag}file found by:$ET${end}"
    validate
    patch -f "${R[@]}" "${dry[@]}" < "$file"
    case "$?" in # check patch exit codes
        0) add_mark "$file" "$M";;
        1) add_mark "$file" "F";;
        *) echo "[$?]:${red}SERIOUS ERROR!${end}";;
    esac
}

main() {
    check_existance
    get_opt "$@"
    non_existence_msg
    if [[ $solo_n ]]; then # if variable defined
        cmmnd $solo_n
    else
        INSIDE_READ_LINE_LOOP=1
        IN=3
        exec 3<&0 # N=IN, for 'read commands' inside read line loop
        reverse_order
        # read line by line
        while IFS= read -r line; do
            cmmnd "$line"
        done <<< "$ORDER"
        echo "${grn}END OF PATCH LIST REACHED${end}"
    fi
}

main "$@"
