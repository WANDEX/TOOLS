#!/bin/sh
# st -e ***.sh executes but immediately closes this new window? Then use me!
# example usage: st -e shell.sh font_test.sh
"$@"
exec "$SHELL"
