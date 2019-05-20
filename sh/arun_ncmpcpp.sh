#!/bin/sh
sleep 5
i3-msg workspace $WS10
$TERMINAL -e ncmpcpp --config /home/wndx/.config/ncmpcpp/config
# return to workspace 1
i3-msg workspace $WS1
