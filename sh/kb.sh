#!/bin/sh
CURRENT_VARIANT=$(setxkbmap -query | grep -i 'variant:' | awk '{print $2}' | sed "s/[,].*$//")
if [ "$CURRENT_VARIANT" != "colemak" ]; then
    setxkbmap -model pc104 -layout us,ru -variant colemak, -option grp:caps_toggle,grp_led:scroll
    notify-send -u low "⌨ COLEMAK"
else
    setxkbmap -model pc104 -layout us,ru -option grp:caps_toggle,grp_led:scroll
    notify-send -u low "⌨ QWERTY"
fi
xset r rate 200 50

