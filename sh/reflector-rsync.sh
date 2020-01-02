#!/bin/bash
# requires sudo for updating servers in '/etc/powerpill/powerpill.json'
declare -a servers
servers=($(reflector -p rsync --age 24 --fastest 50 --latest 25 --sort rate | grep -o 'rsync:\/\/.*'))
linesToWrite=$(printf "      \"%s\",\\\n" "${servers[@]}" | head -c -3 )
perl -i -0pE 's|([[:blank:]]+\"rsync://[^\]]+)|'"${linesToWrite}"'\n    |gs' /etc/powerpill/powerpill.json
