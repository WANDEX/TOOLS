#!/bin/sh
# clock in new terminal window
# requires: defaultfontsize patch for st, or hardcode font name:size yourself
st -z 40 -e loop.sh -s60 -c clock
