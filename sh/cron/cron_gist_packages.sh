#!/bin/sh
# cron script that pushes to gist explicitly installed packages
# pacman, aur

CSCRDIR="${CSCRDIR:-"$HOME/.cache/cscripts"}"
SCRIPTS="${SCRIPTS:-"$HOME/source/scripts"}"

DIR="$CSCRDIR/cron/packages"
[ ! -d "$DIR" ] && mkdir -p "$DIR"
PACMAN_CACHE="$DIR/pacman"
AUR_CACHE="$DIR/aur"

pacman_list="$(pacman -Qqe -n)"
aur_list="$(yay -Qqe -m --aur)"

# tail to skip first 3 lines
pchanges="$(echo "$pacman_list" | diff -N -U0 "$PACMAN_CACHE" - | tail -n +4)"
achanges="$(echo "$aur_list" | diff -N -U0 "$AUR_CACHE" - | tail -n +4)"

# if not empty it's differ -> update cache file
[ -n "$pchanges" ] && _pac=1; echo "$pacman_list" > "$PACMAN_CACHE"
[ -n "$achanges" ] && _aur=1; echo "$aur_list" > "$AUR_CACHE"

# if any of the following variables defined -> do git commands
if [ "$_pac" ] || [ "$_aur" ]; then
    cd "$DIR" || exit
    [ ! -d .git ] && exit # exit if current dir doesn't have .git dir
    time="$(date "+%T")"
    message="$(printf "%s\n\n%s\n\n%s\n" "auto commit at: $time" "$achanges" "$pchanges")"
    git add .
    git commit -m "$message"
    git push origin
fi
