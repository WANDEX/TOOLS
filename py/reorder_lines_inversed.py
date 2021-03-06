#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""reorder_lines_inversed.py.

This module is designed to reorganize the string sequence of a simple text
document. There are 2 types of string sequence reorganization in reverse
order: strict and blocks.
In the strict reorganization method, each row is rearranged in reverse order.
In the block reorganization method, the rows are rearranged in accordance with
the entered string delimiter (separator).
That is, if you need to swap strings using an empty string as a separator,
but not swap strings without an empty string between them.
Use default block reorganization method without entering delimiter.

!!! Look closely at lines that contains - 'line five!' 'line sixth!' !!!
|    STRICT REORDER EXAMPLE    |    BLOCK REORDER EXAMPLE    |
|    (source document):        |    (source document):       |
|        1 line one            |        1 line one           |
|        2 (2 empty_line)      |        2 (2 empty_line)     |
|        3 line three          |        3 line three         |
|        4 (4 empty_line)      |        4 (4 empty_line)     |
|        5 line five!          |        5 line five!         |
|        6 line sixth!         |        6 line sixth!        |
|    (output document):        |    (output document):       |
|        1 line sixth!         |        1 line five!         |
|        2 line five!          |        2 line sixth!        |
|        3 (4 empty_line)      |        3 (4 empty_line)     |
|        4 line three          |        4 line three         |
|        5 (2 empty_line)      |        5 (2 empty_line)     |
|        6 line one            |        6 line one           |
"""

__author__ = "WANDEX"

from os import getcwd, path
from typing import List

FILE = ""

while not path.exists(FILE):
    print("ENTER VALID RELATIVE/FULL FILE PATH WITH EXTENSION:\n")
    FILE = input("file: ")
    if FILE.startswith("\\"):
        CURRENT_DIR = getcwd()
        FILE = CURRENT_DIR + FILE
        print("relative file path:\n" + FILE)


OUTPUT = input("output (if empty ' + _new'): ")

if OUTPUT.isspace() or OUTPUT == "":
    PAIR = path.splitext(FILE)
    OUTPUT = PAIR[0] + "_new" + PAIR[1]


ENCODING = input("encoding (if empty 'UTF-8'): ").lower() or "utf-8"


def idelimiter():
    """input string delimiter.

    By default empty_line is used.
    """
    empty_line = "\n"
    delimiter = input("delimiter (if empty - 'empty line'): ")
    return delimiter + empty_line


def ireorder():
    """input string reorder method.

    Requires manual entering - 'strict' or 'blocks'.
    """
    reorder = input("reorder method('strict'/'blocks'): ").lower()
    return reorder


def strict(f_in, f_out):
    """strict reorder method.

    In the strict reorganization method, each row is rearranged in
    reverse order.
    """
    f_out.writelines(reversed(f_in.readlines()))
    print("SUCCESS STRICT REORDER COMPLETE")


def blocks(f_in, f_out):
    """blocks reorder method.

    In the block reorganization method, the rows are rearranged in
    accordance with the entered string delimiter (separator).
    """
    blocks_list: List[str] = []
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
            print(
                "SOMETHING HAPPENED AT LINE: {0}\n"
                "STRING CONTENT: {1}".format(line_counter, line)
            )

    f_out.writelines(blocks_list)
    print("SUCCESS BLOCKS REORDER COMPLETE")


def execute():
    """main execute method."""
    with open(FILE, "r", 1, ENCODING, errors="replace") as f_in, open(
            OUTPUT, "w", 1, ENCODING, errors="replace"
    ) as f_out:
        reorder = ireorder()
        if reorder == "strict":
            strict(f_in, f_out)
        elif reorder == "blocks":
            blocks(f_in, f_out)
        else:
            print("THERE'S NO SUCH METHOD, TYPE IN ONE OF THE FOLLOWING.")
            execute()


execute()
