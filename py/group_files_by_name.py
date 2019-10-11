#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
from collections import Counter
from itertools import count

S_PATH = "/home/wndx/Downloads/Pictures/hotline_miami/images/"
l_fullpath = []
l_filenames = []


def validate_path(s_path):
    if os.path.isdir(s_path):
        print("Provided path is directory:\n{0}".format(str(s_path)))
    else:
        print("Provided path is not directory:\n{0}".format(str(s_path)))
        print("Exiting.")
        quit()


def get_file_paths(s_path):
    d_fullpath = {}
    for (dirpath, dirnames, filenames) in os.walk(s_path):
        for filename in filenames:
            d_fullpath.update({dirpath: filename})
            l_fullpath.extend(d_fullpath.items())


def line_by_line():
    for line in l_fullpath:
        print("{0}".format(line))


def main():
    validate_path(S_PATH)
    get_file_paths(S_PATH)
    # print(l_fullpath)
    line_by_line()
    print(len(l_fullpath))


main()
