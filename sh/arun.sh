#!/bin/sh
sleep 3
sh arun_telegram.sh &>/dev/null &
sleep 2
sh arun_pulseeffects.sh &>/dev/null &
sleep 2
sh arun_ncmpcpp.sh &>/dev/null &
sleep 3
sh arun_chrome.sh &>/dev/null &
