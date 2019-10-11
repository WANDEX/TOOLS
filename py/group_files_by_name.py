#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
from collections import Counter

S_PATH = "/home/wndx/Downloads/Pictures/hotline_miami/images/"
l_fullpath = []


def validate_path(s_path):
    if os.path.isdir(s_path):
        print("Provided path is directory:\n{0}".format(str(s_path)))
    else:
        print("Provided path is not directory:\n{0}".format(str(s_path)))
        print("Exiting.")
        quit()


def get_file_paths(s_path):
    for (dirpath, dirnames, filenames) in os.walk(s_path):
        l_fullpath.extend(os.path.join(dirpath, filename) for filename in filenames)

    # print("file_count:{0}".format(len(l_fullpath)))


def main():
    validate_path(S_PATH)
    get_file_paths(S_PATH)
    print(l_fullpath)
    print("files:{0}".format(len(l_fullpath)))


main()
