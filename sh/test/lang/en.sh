#!/bin/sh
# use $1 to highlight letter
echo "A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z" | grep --color=auto -i "$1"
