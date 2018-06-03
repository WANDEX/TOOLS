#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Main module."""
from os import path

file = ""

while (not path.exists(file)):
    print("ENTER VALID FILE IN CURRENT DIRECTORY OR FULL PATH WITH EXTENSION\n[" + str(file) + "]")
    file = input("file: ")

output = input("output(if empty '  + _new'): ")

if (output.isspace() or output == ""):
    pair = path.splitext(file)
    output = pair[0] + "_new" + pair[1]

encoding = input("encoding(if empty 'UTF-8'): ").lower() or "utf-8"


def idelimiter():
    emptyline = "\n"
    delimiter = input("delimiter(if 'empty line' - nothing): ")
    return delimiter + emptyline


def reorder_method():
    irmethod = input("reorder method('strict'/'blocks'/'...'): ").lower()
    return(irmethod)


def strict(f_in, f_out):
    f_out.writelines(reversed(f_in.readlines()))
    print("SUCCESS STRICT REORDER COMPLETE")


def blocks(f_in, f_out):
    blocks_list = []
    line_index = 0
    line_counter = 0
    delimiter = idelimiter()

    for line in f_in:
        line_counter += 1
        if line == delimiter:
            line_index = 0
            blocks_list.insert(line_index, line)
        elif line != delimiter:
            blocks_list.insert(line_index, line)
        else:
            print("SOMETHING HAPPENED AT LINE: {0}\n, STRING CONTENT: {1}".format(str(line_counter), str(line)))
        line_index += 1

    f_out.writelines(blocks_list)
    print("SUCCESS BLOCKS REORDER COMPLETE")


def reorder():
    with open(file, 'r', 1, encoding, errors='replace') as f_in, open(output, 'w', 1, encoding) as f_out:
        rmethod = reorder_method()
        if rmethod == "strict":
            strict(f_in, f_out)
        elif rmethod == "blocks":
            blocks(f_in, f_out)
        else:
            print("THERE'S NO SUCH METHOD, TYPE IN ONE OF THE FOLLOWING.")
            reorder()


reorder()
