#!/bin/sh
# get workspace string names
s_ws1=$(grep 'set $ws1 ' ~/.config/i3/config | sed -n -e 's/^.*set $ws1 //p')
s_ws2=$(grep 'set $ws2 ' ~/.config/i3/config | sed -n -e 's/^.*set $ws2 //p')
s_ws3=$(grep 'set $ws3 ' ~/.config/i3/config | sed -n -e 's/^.*set $ws3 //p')
s_ws4=$(grep 'set $ws4 ' ~/.config/i3/config | sed -n -e 's/^.*set $ws4 //p')
s_ws5=$(grep 'set $ws5 ' ~/.config/i3/config | sed -n -e 's/^.*set $ws5 //p')
s_ws6=$(grep 'set $ws6 ' ~/.config/i3/config | sed -n -e 's/^.*set $ws6 //p')
s_ws7=$(grep 'set $ws7 ' ~/.config/i3/config | sed -n -e 's/^.*set $ws7 //p')
s_ws8=$(grep 'set $ws8 ' ~/.config/i3/config | sed -n -e 's/^.*set $ws8 //p')
s_ws9=$(grep 'set $ws9 ' ~/.config/i3/config | sed -n -e 's/^.*set $ws9 //p')
s_ws0=$(grep 'set $ws0 ' ~/.config/i3/config | sed -n -e 's/^.*set $ws0 //p')

export WS1=$s_ws1
export WS2=$s_ws2
export WS3=$s_ws3
export WS4=$s_ws4
export WS5=$s_ws5
export WS6=$s_ws6
export WS7=$s_ws7
export WS8=$s_ws8
export WS9=$s_ws9
export WS10=$s_ws0
