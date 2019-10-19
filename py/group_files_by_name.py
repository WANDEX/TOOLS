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

    extensible_f_list = []
    temp_f_list = []
    last_element = itemgetter(-1)
    for file in f_list:
        extensible_f_list.append(file)
        print("extensible_f_list:{0}".format(extensible_f_list))
        print("file:{0}".format(file))

        if len(get_common_start(extensible_f_list)) > 0:
            temp_f_list = extensible_f_list.copy()
        else:
            print("clear at file:{0}".format(file))
            extensible_f_list.clear()

        if len(get_common_start(extensible_f_list)) == 0:
            extensible_f_list.append(file)
            if last_element(common_prefix) != get_common_start(temp_f_list):
                common_prefix.append(get_common_start(temp_f_list))

        print("temp_f_list:{0}".format(temp_f_list))
        print("prefix:\t{0}".format(last_element(common_prefix)))
        print()
    if last_element(common_prefix) != get_common_start(temp_f_list):
        common_prefix.append(get_common_start(temp_f_list))
    common_prefix.pop(0)  # remove first empty element
    print("common_prefix:{0}".format(common_prefix))


def file_loop(f_list):
    l_paths = []
    l_names = []
    for file in f_list:
        l_paths.append(file[0])
        l_names.append(file[1])
    get_prefixes(l_names[1:11])


def main():
    test_list = ["objMonitors_0.png", "objMonitors_1.png", "objMonitors_2.png", "shit"]
    validate_path(S_PATH)
    get_file_paths(S_PATH)
    # print(l_fullpath)
    # line_by_line()
    # print(long_substr())
    # print(l_fullpath.pop(0)[1])
    # get_prefixes(test_list)
    file_loop(l_fullpath)
    print(len(l_fullpath))


main()
