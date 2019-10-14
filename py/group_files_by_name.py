#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import collections
from operator import itemgetter
from itertools import count

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
    d_fullpath = {}
    for (dirpath, dirnames, filenames) in os.walk(s_path):
        for filename in filenames:
            d_fullpath.update({dirpath: filename})
            l_fullpath.extend(d_fullpath.items())
    l_fullpath.sort(key=itemgetter(1))


def line_by_line():
    for line in l_fullpath:
        print("{0}".format(line))


def long_substr(data):
    substr = ""
    if len(data) > 1 and len(data[0]) > 0:
        for i in range(len(data[0])):
            for j in range(len(data[0]) - i + 1):
                if j > len(substr) and is_substr(data[0][i:i+j], data):
                    substr = data[0][i:i+j]
    return substr


def is_substr(find, data):
    if len(data) < 1 and len(find) < 1:
        return False
    for i in range(len(data)):
        if find not in data[i]:
            return False
    return True


def longest_common_substring():
    l_filenames = []
    for line in l_fullpath:
        l_filenames.append(line[1])
        # print("{0}".format(line[1]))
    print(l_filenames[0:10])
    long_substr(l_filenames)


def main():
    validate_path(S_PATH)
    get_file_paths(S_PATH)
    # print(l_fullpath)
    line_by_line()
    # print(long_substr())
    # print(l_fullpath.pop(0)[1])
    print(len(l_fullpath))
    # longest_common_substring()


main()
