#!/bin/sh
sleep 3
i3-msg workspace $WS9
telegram-desktop
# return to workspace 1
i3-msg workspace $WS1
