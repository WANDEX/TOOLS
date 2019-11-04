#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import collections
import pathlib
from re import split
from operator import itemgetter
from itertools import count

S_PATH = "/home/wndx/Downloads/Pictures/hotline_miami/hotline_miami/"
# S_PATH = "/home/wndx/Downloads/Pictures/hotline_miami/test/"
l_fullpath = []
l_group = []


def sort_natural(l, key):
    """ Sort the given iterable in the way that humans expect."""
    convert = lambda text: int(text) if text.isdigit() else text
    alphanum_key = lambda item: [convert(c) for c in split('([0-9]+)', key(item))]
    return l.sort(key=alphanum_key)


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
    sort_natural(l_fullpath, itemgetter(1))


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


def processed_files(range=0):
    """ Simple output message. """
    if range <= 0:
        range = len(l_fullpath)
    processed = "Number of files processed: {0}".format(str(range))
    total = "Total number of files in path: {0}".format(str(len(l_fullpath)))
    msg = "\n{0}\n{1}".format(processed, total)
    return msg


def file_loop(f_list, range=0):
    if range <= 0:
        get_prefixes(l_fullpath)
    else:
        get_prefixes(l_fullpath[:range])


def make_new_root_dir():
    old_path = pathlib.PurePath(S_PATH)
    new_dir_name = old_path.name + "_grouped"
    new_dir_path = old_path.parent.joinpath(new_dir_name)
    pathlib.Path(new_dir_path).mkdir(exist_ok=True)
    print("\nNew dir path is:\n{0}\n".format(new_dir_path))
    return new_dir_path




def main(range=0):
    validate_path(S_PATH)
    get_file_paths(S_PATH)
    file_loop(l_fullpath, range)
    print("\nl_group:")
    print(*l_group, sep="\n")
    # print(*l_fullpath, sep="\n")
    print(processed_files(range))
    make_new_root_dir()


main()
