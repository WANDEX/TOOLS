#!/bin/sh
# check which dependency libs are not installed for given binary as first parameter.

# colors example
# printf "%s\n" "Text in ${red}red${end}, white and ${blu}blue${end}."
red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

# list libs required by provided binary
LIBS=$(objdump -p $1 | grep NEEDED | awk '{ $1=""; print substr($0,2) }')

exitCode() {
    ### Exit codes:
    ### 0 = match found
    ### 1 = no match found
    ### 2 = error
    binaryF=$1
    pacman -F $binaryF | grep -q installed | echo $?
}

while IFS= read -r line; do
    statusMsg=""
    statusCode="$(exitCode "$line")"
    if [ "$statusCode" == "0" ]; then
        statusMsg="${cyn}[installed]${end}..."
    elif [ "$statusCode" == "1" ]; then
        statusMsg="${red}[REQUIRED]${end}...."
    else
        statusMsg="${red}[ERROR]${end}......."
    fi
    printf "$statusMsg $line\n"
done <<< "$LIBS"

printf "\nTo find out in which Repo & Package lib exists:\n"
printf "${cyn}pacman -F${end} ...\n"
