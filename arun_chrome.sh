#!/bin/sh
sleep 7
i3-msg workspace $WS2
google-chrome-stable
# return to workspace 1
i3-msg workspace $WS1
