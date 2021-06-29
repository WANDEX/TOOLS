#!/bin/sh
# automate the boring task of creating simple .diff file to not use
# git diff files > create "diff -up" patches
#
# apply original patch
# create diff between my files & original files as a whole dir
# reverse with modified version of patch

parent_dir="$(find ../*/ -type d -path "*-*")"
dir_for_diffs="${1:-$parent_dir}"
[ ! -d "$dir_for_diffs" ] && echo "dir_for_diffs:[$dir_for_diffs] not found. exit." && exit 1

old_dir="${2:-orig}"
new_dir="${3:-modified}"
odir="./patch/${old_dir}/"
ndir="./patch/${new_dir}/"
[ ! -d "$odir" ] && echo "$odir not found. exit." && exit 1
[ ! -d "$ndir" ] && echo "$ndir not found. exit." && exit 1

patch_files=$(find "$odir"* -type f -path "*.diff")

print_stats() {
    bname="$1"
    i="$(echo "$i+1" | bc)"
    printf "${CYN_S}[%s/%s]${END}\t${YEL}%s${END}\n" \
        "$i" "$total" "$bname"
}

error_check() {
    errc="$1"
    text="$2"
    case "$text" in
        "CREATING") e=1 ;; # diff - returns: 0 - same | 1 - different | 2 - trouble
        *) e=0 ;;
    esac
    if [ "$errc" -ne "$e" ]; then
        printf "${RED_S}%s${END}\n%s\n" \
        "ERROR WHILE ${text} PATCH, EXIT." "$old_patch"
        if [ "$text" =  "APPLYING" ]; then
            printf "${MAG} %s ${END}\n" "trying to reverse already applied hunks:"
            patch -p1 -f -R < "$old_patch"
            printf "${CYN} %s ${END}\n" "doing make clean:"
            make clean
        fi
        exit "$errc"
    fi
}

total="$(echo "$patch_files" | wc -l)"
i=0
for old_patch in $patch_files; do
    bname="$(basename "$old_patch")"
    new_patch="${ndir}${bname}"
    print_stats "$bname"

    # apply orig patch
    patch -p1 -f < "$old_patch"
    error_check "$?" "APPLYING"

    # create new_patch
    diff -up "$dir_for_diffs" ./ > "$new_patch"
    error_check "$?" "CREATING"

    # reverse with new patch (to validate that patch is working)
    patch -p1 -f -R < "$new_patch"
    error_check "$?" "REVERSING"
done

if [ "$total" -eq "$i" ]; then
    printf "\n${GRN_S}%s${END}\n" "FINISHED WITHOUT ERRORS."
else
    printf "\n${RED_S}%s${END}\n" "FINISHED WITH ERRORS?... wait what???"
fi

