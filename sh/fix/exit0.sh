#!/bin/sh
# return 0 instead of another program exit code status.
# usage example:
# st -t pomodoro -n opaque -e exit0.sh rlwrap pomodoro
"$@"
exit 0
