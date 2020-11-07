#!/bin/bash
# execute script in new terminal window and wait for input (without this, the
# terminal window will be closed immediately upon completion of the script.)
# usage example: st -e any_key.sh echo "end?"
"$@"
read -p "press any key..." -n 1 -r
