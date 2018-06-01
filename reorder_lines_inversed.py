#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Main module."""
from os import path
# import re

file = ""

while (not path.exists(file)):
    print("ENTER VALID FILE IN CURRENT DIRECTORY OR FULL PATH WITH EXTENSION\n[" + str(file) + "]")
    file = input("file: ")

output = input("output(if empty '  + _new'): ")

if (output.isspace() or output == ""):
    pair = path.splitext(file)
    output = pair[0] + "_new" + pair[1]

encoding = input("encoding(if empty 'UTF-8'): ") or "utf-8"

print(str(file + " " + output + " " + encoding))


def reorder_method():
    irmethod = input("reorder method('strict'/'blocks'/'...'): ")
    return(irmethod)


def strict(f_in, f_out):
    f_out.writelines(reversed(f_in.readlines()))
    print("SUCCESS STRICT REORDER COMPLETE")


def blocks(f_in, f_out):
    blocks_list = []
    line_index = 0

    for line in f_in:
        empty_line = not line.strip()
        if empty_line:
            line_index = 0
            blocks_list.insert(line_index, line)
        elif not empty_line:
            blocks_list.insert(line_index, line)
        line_index += 1

    f_out.writelines(blocks_list)
    print("SUCCESS BLOCKS REORDER COMPLETE")


def reorder():
    with open(file, 'r', 1, encoding, errors='replace') as f_in, open(output, 'w', 1, encoding) as f_out:
        if reorder_method() == "strict":
            strict(f_in, f_out)
        else:
            blocks(f_in, f_out)


reorder()
