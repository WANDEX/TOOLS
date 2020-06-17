#!/bin/sh
# auto run (execute) scripts inside this file dir

task() {
    echo "$1" | xargs -t -o -I % sh -c 'sleep 0.5 && % &>/dev/null'
}

main() {
    local abs_dir_path=$(dirname $(realpath "$0"))
    # get abs path of all files excluding .dot files and this file itself
    local scripts=$(find "$abs_dir_path" -type f -executable \( ! -iname ".*" ! -iname $(basename "$0") \))

    for script in "$scripts"; do
        task "$script"
    done

    sleep 2 && i3-msg -q workspace $WS1
}

main "$@"

