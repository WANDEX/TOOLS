#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import collections
from operator import itemgetter
from itertools import count

# S_PATH = "/home/wndx/Downloads/Pictures/hotline_miami/hotline_miami/"
S_PATH = "/home/wndx/Downloads/Pictures/hotline_miami/test/"
l_fullpath = []
l_group = []


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


def get_common_start(seq):
    if not seq:
        return ""
    s1, s2 = min(seq), max(seq)
    length = min(len(s1), len(s2))
    if length == 0:
        return ""
    for i in range(length):
        if s1[i] != s2[i]:
            return s1[0:i]
    return s1[0:length]


def count_words(str):
    c = 1
    for i in range(1, len(str) - 1):
        if (str[i].isupper()):
            c += 1
    return c


def str_filter(string):
    bad_chars = ["_", ";", ":", "!", ",", "*"]
    numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    # bad_chars.extend(numbers)
    # string = string[:string.find(".")]  # remove all characters after "."
    l_filter = list(filter(lambda i: i not in bad_chars, string))
    filtered = str().join(l_filter)
    return filtered


def get_prefixes(f_list):
    d_group = {}
    previous_file = ""
    # last_element = itemgetter(-1)
    for file in f_list:
        if previous_file:
            # FIX: common_prefix is empty list first
            temp_temp_f_list = [previous_file[1], file[1]]
            test_prefix = str(get_common_start(temp_temp_f_list)).rstrip("_ ")
            if len(test_prefix) > len(previous_file[1]) - len(previous_file[1]) // 2:
                d_group.update({previous_file: test_prefix})
                d_group.update({file: test_prefix})
        previous_file = file
    l_group.extend(d_group.items())


def file_loop(f_list, range=0):
    if range <= 0:
        get_prefixes(l_fullpath)
    else:
        get_prefixes(l_fullpath[:range])


def main():
    validate_path(S_PATH)
    get_file_paths(S_PATH)
    file_loop(l_fullpath, 0)
    # print(count_words("sprVHSStapes"))
    # print(str_filter("sprVHSStapes_12.png"))
    print("\nl_group:")
    print(*l_group, sep="\n")
    # print(*l_fullpath, sep="\n")
    print("\nNumber of files: {0}".format(str(len(l_fullpath))))


main()
