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


def get_prefixes(f_list, min_prefix_width=3, word_count=1):
    extensible_f_list = []
    temp_f_list = []
    common_prefix = [""]
    d_group = {}
    last_element = itemgetter(-1)
    for file in f_list[:20]:
        extensible_f_list.append(file)
        # print("extensible_f_list:{0}".format(extensible_f_list))

        if (
                count_words(get_common_start(extensible_f_list)) > word_count and
                len(get_common_start(extensible_f_list)) > min_prefix_width
           ):
            temp_f_list = extensible_f_list.copy()
        else:
            # print("clear at file:{0}".format(file))
            extensible_f_list.clear()

        if len(get_common_start(extensible_f_list)) == 0:
            extensible_f_list.append(file)
            if last_element(common_prefix) != get_common_start(temp_f_list):
                common_prefix.append(get_common_start(temp_f_list))

        # print(file)
        d_group.update({file: last_element(common_prefix)})
        l_group.extend(d_group.items())

        print("file:{0}\t[temp_f_list]:\n{1}".format(file, temp_f_list))
        # print("prefix:\t{0}".format(last_element(common_prefix)))
        print()
    if last_element(common_prefix) != get_common_start(temp_f_list):
        common_prefix.append(get_common_start(temp_f_list))
    common_prefix.pop(0)  # remove first empty element
    print("common_prefix:\n{0}".format(common_prefix))
    print("element_count:{0}".format(len(common_prefix)))


def file_loop(f_list, min_prefix_width=3, range=1000):
    l_paths = []
    l_names = []
    for file in f_list:
        l_paths.append(file[0])
        # l_names.append(file[1])
        l_names.append(str_filter(file[1]))

        # print("file?:{0}".format(file))
    if range <= 0:
        get_prefixes(l_names, min_prefix_width)
    else:
        get_prefixes(l_names[:range], min_prefix_width)

    # for file in f_list:


# def stick_to_group(f_list, d_group):
    # for file in f_list:


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
