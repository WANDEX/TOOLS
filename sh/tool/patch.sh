#!/bin/sh
# apply/reverse all patches easily,
# to keep the stacking order of the patches.

red=$'\e[1;31m'; grn=$'\e[1;32m'; yel=$'\e[1;33m'; blu=$'\e[1;34m'; mag=$'\e[1;35m'; cyn=$'\e[1;36m'; end=$'\e[0m'
red_i=$'\e[1;41m'; grn_i=$'\e[1;42m'; yel_i=$'\e[1;43m'; blu_i=$'\e[1;44m'; mag_i=$'\e[1;45m'; cyn_i=$'\e[1;46m'; def_i=$'\e[1;7m'
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
        msg="\n"
        num=$(echo "$ORDER" | grep "$file" | awk '{print $1}' | sed "$sed_num")
        mrk=$(echo "$ORDER" | grep "$file" | awk '{print $1}' | sed -n "$sed_mrk")
        dir=$(dirname $file)
        bsn=$(basename $file)
        OUT=$(printf "%s%s %s%s" "${mag}$num${end}" \
                                "${red}$mrk${end}" \
                                "${blu}$dir/${end}" \
                                "${cyn}$bsn${end}")
    fi
    [[ $solo_n ]] && msg=""
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
    SHORT=a:hlm:RS:s:y
    LONG=add:,help,list,mark:,reverse,select:,solo:,yes,dry-run,init
    OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")
    # PLACE FOR OPTION DEFAULTS
    make_clean=1
    debug=0
    YES=0
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
            printf "${mag}[${end}${red}$1${mag}]${end} ^ ABOVE PATCHES SELECTED BY MARK\n\n"
            ;;
        -R|--reverse)
            R=(--reverse)
            ORDER=$(echo "$ORDER" | tac)
            ;;
        -S|--select)
            shift
            ORDER=$(echo "$ORDER" | grep -i "$1")
            print_colored all
            printf "${mag}[${end}${red}$1${mag}]${end} ^ ABOVE PATCHES SELECTED\n\n"
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
        -y|--yes)
            YES=1
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
    if [[ $YES -eq 1 ]]; then
        echo "After confirmation, ${yel}all patches will be applied/reversed at once!${end}"
        echo "${cyn}Based on${end} previous individual patch history ${red}mark${end}."
        Q="Proceed? [y/n] "
        while true; do
            read -p "$Q" -n 1 -r
            case "$REPLY" in
                [Yy]*) break;;
                [Nn]*) echo "exit." && exit 0;;
                *) echo "${red}I don't get it.${end}";;
            esac
        done
    fi
}

validate() {
    if [[ $YES -eq 0 ]]; then
        [[ $solo_n ]] && SA="ONLY this patch?" || SA="this patch?"
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
        printf "${blu}Patch contained${end} ${red}FAILED Hunk${end}"
        printf "${blu} and marked as:${end}${red}F${end}\n"
    fi
    [[ ! $dry ]] && sed -i $lnum"s/^$SEP./$SEP$mark/" "$FILE" &&
    [[ $debug -eq 1 ]] && echo "mark:${red}$mark${end} SET!"
}

statistic() {
    exit_code="$1"
    case "$exit_code" in
        0) ST_S=$(($ST_S + 1)); echo "${grn_i}[OK]${end}^";;
        1) ST_F=$(($ST_F + 1)); echo "${red_i}[FAILED]${end}^";;
        2) ST_E=$(($ST_E + 1)); echo "${red_i}[ERROR]${end}^";;
    esac
    ST_TOTAL=$(($ST_TOTAL + 1))
    [[ $ST_F -eq 0 ]] && ST_F_MSG="" || ST_F_MSG="${red_i} FAILED:$ST_F ${end}"
    [[ $ST_E -eq 0 ]] && ST_E_MSG="" || ST_E_MSG="${red_i} ERROR:$ST_E ${end}"
    [[ $ST_S -eq $ST_TOTAL ]] && ST_S_MSG="" || ST_S_MSG="${grn_i} SUCCESS:$ST_S ${end}"
    STATS_NUM="${cyn_i} [$ST_S/$ST_TOTAL] ${end}"
    SSEP="${def_i} / ${end}"
    [[ $STATS_N_LONG -eq 1 ]] && STATS_NUMS="$SSEP$STATS_NUM" || STATS_NUMS="$SSEP${cyn_i} $ST_TOTAL ${end}"
    STATS_FULL="$ST_S_MSG""$ST_F_MSG""$ST_E_MSG"
    [[ "$ST_S_MSG" == "" ]] && STATS_FULL="${grn_i}[OK]${end}${def_i} ALL PATCHES ARE ${end}${grn_i}[OK]${end}"
}

patch_cmd() {
    file="$1"
    patch -p1 -f "${R[@]}" "${dry[@]}" < "$file"
    case "$?" in # check patch exit codes
        0) statistic 0; add_mark "$file" "$M";;
        1) statistic 1; add_mark "$file" "F";;
        *) statistic 2; echo "[$?]:${red}SERIOUS ERROR!${end}";;
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
    if [[ ! $R ]]; then # if -R option not explicitly specified
        # automatic toggle behavior of patch -R (reverse/apply) option
        case "$(get_patch_mark "$file")" in
            A) R=(--reverse); M="R"; RA="Reverse";;
            N) R=(); M="A"; RA="Apply";;
            R) R=(); M="A"; RA="Apply";;
            F)
                printf "\nPreviously this patch introduced ${red}FAILED Hunks!${end}\n"
                [[ $make_clean -eq 1 ]] && make clean && printf "${cyn}make clean [finished]${end}\n"
                print_colored "$file"
                while true; do
                    if [[ $INSIDE_READ_LINE_LOOP -eq 1 ]]; then
                        read -p "Apply/Reverse this patch? [a/r] " -n 1 -r <&$IN
                    else
                        read -p "Apply/Reverse this patch? [a/r] " -n 1 -r
                    fi
                    echo "" # move to a new line
                    case "$REPLY" in
                        [Aa]*) R=(); M="A"; RA="Apply"; break;;
                        [Rr]*) R=(--reverse); M="R"; RA="Reverse"; break;;
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
}

main() {
    check_existance
    get_opt "$@"
    non_existence_msg
    if [[ $solo_n ]]; then # if variable defined
        cmmnd $solo_n
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
        [[ $STATS_FULL_ON -eq 1 ]] && printf "$STATS_FULL"
        [[ $STATS_NUMS_ON -eq 1 ]] && printf "$STATS_NUMS\n"
    fi
}

main "$@"

