#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Main module."""
import os

file = ""

while not os.path.exists(file):
    print("ENTER VALID RELATIVE/FULL FILE PATH WITH EXTENSION:\n"
          "[" + file + "]")
    file = input("file: ")
    if file.startswith("\\"):
        current_dir = os.getcwd()
        file = current_dir + file
        print("relative file path:\n" + file)

output = input("output (if empty ' + _new'): ")

if output.isspace() or output == "":
    pair = os.path.splitext(file)
    output = pair[0] + "_new" + pair[1]

encoding = input("encoding (if empty 'UTF-8'): ").lower() or "utf-8"


def idelimiter():
    empty_line = "\n"
    delimiter = input("delimiter (if empty - 'empty line'): ")
    return delimiter + empty_line


def ireorder():
    ireorder = input("reorder method('strict'/'blocks'): ").lower()
    return(ireorder)


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
        line_index += 1
        if line != delimiter:
            blocks_list.insert(line_index, line)
        elif line == delimiter:
            line_index = 0
            blocks_list.insert(line_index, line)
        else:
            print("SOMETHING HAPPENED AT LINE: {0}\n"
                  "STRING CONTENT: {1}".format(str(line_counter), str(line)))

    f_out.writelines(blocks_list)
    print("SUCCESS BLOCKS REORDER COMPLETE")


def execute():
    with open(file, 'r', 1, encoding, errors='replace') as f_in, \
         open(output, 'w', 1, encoding, errors='replace') as f_out:
        reorder = ireorder()
        if reorder == "strict":
            strict(f_in, f_out)
        elif reorder == "blocks":
            blocks(f_in, f_out)
        else:
            print("THERE'S NO SUCH METHOD, TYPE IN ONE OF THE FOLLOWING.")
            execute()


execute()
