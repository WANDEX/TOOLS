#!/bin/sh
# apply/reverse all patches easily,
# to keep the stacking order of the patches.

# SOURCE GLOBALLY DEFINED TERMINAL COLOR VARIABLES
# shellcheck disable=SC1091
# shellcheck source=$ENVSCR/termcolors
TC="$ENVSCR/termcolors" && [ -r "${TC}" ] && . "${TC}"

SEP='|'; NLS=')'
ST_S=0; ST_F=0; ST_E=0; ST_TOTAL=0

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
    -S, --select    Select patches found by ... in their file path (dir name etc.)
    -s, --solo      Single shot mode for one of the patches from --list,
                    '-s N', by default it is assumed that this patch is not applied!
                    first usage - apply patch, second - reverse patch, and so forth.
    -y, --yes       Always assume that the answer is yes before each patch command
    -Y, --auto      Auto mode without interactive questions and prompts.
    --dry-run       Print the results of applying the patches without actually
                    changing any files.
                    ${RED}(each patch file independently, not a cascade of changes)${END}
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
        ORDER=$(sed "s/[[:space:]]*#.*$//g; /^[[:space:]]*$/d" "$FILE")
        ORDER=$(echo "$ORDER" | nl -w2 -n"rn" -s"$NLS")
        N_MAX=$(echo "$ORDER" | wc -l)
    else
        FILE_NOT_FOUND=1
    fi
}

print_colored() {
    sed_num="s/.$//"
    sed_mrk="s/[[:digit:]]*$NLS$SEP\(.\).*$/\1/p"
    if [ "$1" = all ]; then
        arg="$ORDER"
        msg="patch order:"
        tmpd="${TMPDIR:-/tmp/}$(basename "$0")" && mkdir -p "$tmpd"
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
                $1 = "'"${MAG}"'" $1 "'"${END}"'";
                $2 = "'"${RED}"'" $2 "'"${END}"'";
                $3 = "'"${BLU}"'" $3 "'"${END}"'";
                $4 = "'"${CYN}"'" $4 "'"${END}"'";
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
        num=$(echo "$ORDER" | grep "$file" | awk '{print $1}' | sed "$sed_num")
        mrk=$(echo "$ORDER" | grep "$file" | awk '{print $1}' | sed -n "$sed_mrk")
        dir=$(dirname "$file")
        bsn=$(basename "$file")
        OUT=$(printf "%s%s %s%s" "${MAG}$num${END}" \
                                "${RED}$mrk${END}" \
                                "${BLU}$dir/${END}" \
                                "${CYN}$bsn${END}")
    fi
    [ "$solo_n" ] && msg=""
    printf "%s\n%s\n" "$msg" "$OUT"
}

add_patch() {
    patch_file_path="$1"
    SPACES='  '
    printf "%s\n" "${SEP}N${SPACES}${patch_file_path}" >> "$FILE"
    echo "${YEL}${patch_file_path}${END}"
    echo "patch added to the end of the active_patch_list. exit"
    exit 0
}

get_opt() {
    # Parse and read OPTIONS command-line options
    SHORT=a:hlm:RS:s:yY
    LONG=add:,help,list,mark:,reverse,select:,solo:,yes,auto,dry-run,init
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    make_clean=1
    debug=0
    YES=0
    AUTO=0
    STATS_FULL_ON=1
    STATS_NUMS_ON=1
    STATS_N_LONG=1
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
            printf "%s\n\n" "${MAG}[${END}${RED}${1}${MAG}]${END} ^ ABOVE PATCHES SELECTED BY MARK"
            ;;
        -R|--reverse)
            R=(--reverse)
            ORDER=$(echo "$ORDER" | tac)
            ;;
        -S|--select)
            shift
            ORDER=$(echo "$ORDER" | grep -i "$1")
            print_colored all
            printf "%s\n\n" "${MAG}[${END}${RED}${1}${MAG}]${END} ^ ABOVE PATCHES SELECTED"
            ;;
        -s|--solo)
            shift
            case $1 in
                0*)
                    printf "%s\n%s\n" "${1}" "^ unsupported number! exit."
                    exit 1
                    ;;
                ''|*[!0-9]*)
                    printf "%s\n%s\n" "${1}" "^ IS NOT A NUMBER OF INT! exit."
                    exit 1
                    ;;
                *) solo_n=$1 ;;
            esac
            if [[ $solo_n -gt $N_MAX ]]; then
                echo "[$solo_n] - there is no such list item related to this number. exit"
                exit 1
            fi
            ;;
        -y|--yes)
            YES=1
            ;;
        -Y|--auto)
            AUTO=1
            ;;
        --dry-run)
            dry=(--dry-run)
            ;;
        --init)
            string="# ignores data after # character (comment string)"
            [ ! -d "$DIR" ] && mkdir -p "$DIR" && echo "created dir : ${YEL}$DIR${END}"
            [ ! -f "$FILE" ] && echo "$string" > "$FILE" && echo "created file: ${YEL}$FILE${END}" || echo "this file already exist: ${YEL}$FILE${END}"
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
    if [ "$DIR_NOT_FOUND" ]; then
        echo "${RED}NOT FOUND ANY PATCH DIR INSIDE CURRENT GIT ROOT DIR:${END}"
        echo "${YEL}$GITRDIR${END}"
        echo "Do not forget to ${CYN}cd${END} inside ${CYN}git${END} project, with ${CYN}patch/patches dir${END}. exit."
        exit 1
    elif [ "$FILE_NOT_FOUND" ]; then
        echo "${YEL}$FILE${END}"
        echo "${RED}FILE DOES NOT EXIST!${END} exit."
        exit 1
    fi
}

reverse_order() {
    if [ "$AUTO" -eq 1 ]; then
        # automatically guess Order of Patches Normal/Reverse by the last patch file only!
        # discard first column & trim leading spaces
        _f=$(echo "$ORDER" | tail -n1 | awk '{$1="";print $0}' | sed "s/^[ ]*//")
        case "$(get_patch_mark "$_f")" in
            A) ORDER="$(echo "$ORDER" | tac)" ;;
        esac
    else
        Q="Reverse Order of Patches? ${YEL}(from last to first)${END} [y/n] "
        while true; do
            read -p "$Q" -n 1 -r
            case "$REPLY" in
                [Yy]*) ORDER=$(echo "$ORDER" | tac); break;;
                [Nn]*) break;;
                *) echo "${RED}I don't get it.${END}";;
            esac
        done
    fi
    printf "\nFollowing order will be used, "
    print_colored all
    echo ""
    [ "$AUTO" -eq 1 ] && return # skip following interactive confirmation
    if [ "$YES" -eq 1 ]; then
        echo "After confirmation, ${YEL}all patches will be applied/reversed at once!${END}"
        echo "${CYN}Based on${END} previous individual patch history ${RED}mark${END}."
        Q="Proceed? [y/n] "
        while true; do
            read -p "$Q" -n 1 -r
            case "$REPLY" in
                [Yy]*) break;;
                [Nn]*) echo "exit." && exit 0;;
                *) echo "${RED}I don't get it.${END}";;
            esac
        done
    fi
}

validate() {
    if [ "$YES" -eq 0 ]; then
        [ "$solo_n" ] && SA="ONLY this patch?" || SA="this patch?"
        Q="$RA $SA [y/n] "
        if [[ "$INSIDE_READ_LINE_LOOP" -eq 1 ]]; then
            read -p "$Q" -n 1 -r <&$IN
        else
            read -p "$Q" -n 1 -r
        fi
        echo "" # move to a new line
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            # handle exits from shell or function but don't exit interactive shell
            [ "$0" = "$BASH_SOURCE" ] && exit 0 || return 1
        fi
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
    if [ "$mark" = F ]; then
        printf "${BLU}Patch contained${END} ${RED}FAILED Hunk${END}"
        printf "${BLU} and marked as:${END}${RED}F${END}\n"
    fi
    [ ! "$dry" ] && sed -i $lnum"s/^$SEP./$SEP$mark/" "$FILE" &&
    [ "$debug" -eq 1 ] && echo "mark:${RED}$mark${END} SET!"
}

statistic() {
    exit_code="$1"
    case "$exit_code" in
        0) ST_S=$(($ST_S + 1)); echo "${GRN_S}[OK]${END}^";;
        1) ST_F=$(($ST_F + 1)); echo "${RED_S}[FAILED]${END}^";;
        2) ST_E=$(($ST_E + 1)); echo "${RED_S}[ERROR]${END}^";;
    esac
    ST_TOTAL=$(($ST_TOTAL + 1))
    [ "$ST_F" -eq 0 ] && ST_F_MSG="" || ST_F_MSG="${RED_S} FAILED:$ST_F ${END}"
    [ "$ST_E" -eq 0 ] && ST_E_MSG="" || ST_E_MSG="${RED_S} ERROR:$ST_E ${END}"
    [ "$ST_S" -eq "$ST_TOTAL" ] && ST_S_MSG="" || ST_S_MSG="${GRN_S} SUCCESS:$ST_S ${END}"
    STATS_NUM="${CYN_S} [$ST_S/$ST_TOTAL] ${END}"
    SSEP="${DEF_S} / ${END}"
    [ "$STATS_N_LONG" -eq 1 ] && STATS_NUMS="$SSEP$STATS_NUM" || STATS_NUMS="$SSEP${CYN_S} $ST_TOTAL ${END}"
    STATS_FULL="$ST_S_MSG""$ST_F_MSG""$ST_E_MSG"
    [ "$ST_S_MSG" = "" ] && STATS_FULL="${GRN_S}[OK]${END}${DEF_S} ALL PATCHES ARE ${END}${GRN_S}[OK]${END}"
}

patch_cmd() {
    file="$1"
    patch -p1 -f "${R[@]}" "${dry[@]}" < "$file"
    case "$?" in # check patch exit codes
        0) statistic 0; add_mark "$file" "$M";;
        1) statistic 1; add_mark "$file" "F";;
        *) statistic 2; echo "[$?]:${RED}SERIOUS ERROR!${END}";;
    esac
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
        GREP=$(echo "$ORDER" | grep "^[ ]*$arg$NLS$SEP")
        ET="number"
    fi
    # discard first column & trim leading spaces
    file=$(echo "$GREP" | awk '{$1="";print $0}' | sed "s/^[ ]*//")
    if [ ! "$R" ]; then # if -R option not explicitly specified
        # automatic toggle behavior of patch -R (reverse/apply) option
        case "$(get_patch_mark "$file")" in
            A) R=(--reverse); M="R"; RA="Reverse";;
            N) R=(); M="A"; RA="Apply";;
            R) R=(); M="A"; RA="Apply";;
            F)
                printf "\nPreviously this patch introduced ${RED}FAILED Hunks!${END}\n"
                [ "$make_clean" -eq 1 ] && make clean && printf "%s\n" "${CYN}make clean [finished]${END}"
                print_colored "$file"
                while true; do
                    if [ "$INSIDE_READ_LINE_LOOP" -eq 1 ]; then
                        read -p "Apply/Reverse this patch? [a/r] " -n 1 -r <&$IN
                    else
                        read -p "Apply/Reverse this patch? [a/r] " -n 1 -r
                    fi
                    echo "" # move to a new line
                    case "$REPLY" in
                        [Aa]*) R=(); M="A"; RA="Apply"; break;;
                        [Rr]*) R=(--reverse); M="R"; RA="Reverse"; break;;
                        *) echo "${RED}I don't get it.${END}";;
                    esac
                done
                ;;
            *)
                echo "${RED}ERROR: patch_mark for this file not found!${END}"
                print_colored "$file"
                echo "check your active_patch_list file. exit."
                exit 1
                ;;
        esac
    fi
    print_colored "$file"
    [ "$debug" -eq 1 ] && echo "${MAG}file found by:$ET${END}"
}

main() {
    check_existance
    get_opt "$@"
    non_existence_msg
    if [ "$solo_n" ]; then # if variable defined
        cmmnd "$solo_n"
        validate
        patch_cmd "$file"
    else
        INSIDE_READ_LINE_LOOP=1
        IN=3
        exec 3<&0 # N=IN, for 'read commands' inside read line loop
        reverse_order
        # read line by line
        while IFS= read -r line; do
            cmmnd "$line"
            validate
            patch_cmd "$file"
        done <<< "$ORDER"
        echo ""
        [ "$STATS_FULL_ON" -eq 1 ] && printf "%s" "$STATS_FULL"
        [ "$STATS_NUMS_ON" -eq 1 ] && printf "%s\n" "$STATS_NUMS"
    fi
}

main "$@"

