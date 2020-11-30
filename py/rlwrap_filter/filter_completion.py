#!/usr/bin/python3

""" remove from completion list """

import sys
import os

if 'RLWRAP_FILTERDIR' in os.environ:
    sys.path.append(os.environ['RLWRAP_FILTERDIR'])
else:
    sys.path.append('.')

import rlwrapfilter
import argparse
import pathlib
import re
from signal import SIGKILL
from time import sleep
from threading import Thread

filter = rlwrapfilter.RlwrapFilter()

filter.help_text = "Usage: rlwrap [-options] -z ] remove_from_completion.py <command>\n"\
                   + " remove from completion list"

parser = argparse.ArgumentParser()
parser.add_argument('--add', '-a', type=str, action='append', help="add from file to completion.", required=False)
parser.add_argument('--file', '-f', type=str, action='append', help="file path to exclude regex.", required=False)
parser.add_argument('--regex', '-r', type=str, action='append', help="match regex to exclude", required=False)
args = parser.parse_args()

SPECIAL_C = r'[?/|\\.,:;\'"`<>(){}\[\]]'
NUM_ROW_C = r'[~!@#$%^&+-=]'
SHORTWORD = r'\b\w{,3}\b'  # match words less than N characters
REGEXES_L = [SPECIAL_C, NUM_ROW_C, SHORTWORD]


def kill():
    """ kill script if parent process pid is changed """
    original_ppid = os.getppid()
    while True:
        sleep(5)
        if (original_ppid != os.getppid()):
            os.kill(os.getpid(), SIGKILL)


def convert(lst):
    return tuple(set(' '.join(lst).split()))


def get_blacklisted_words():
    files_data = ""
    for path in args.file:
        with open(pathlib.Path(path)) as file:
            files_data += file.read()
    match_list = []
    regexes = []
    regexes.extend(args.regex)
    regexes.extend(REGEXES_L)
    for regex in regexes:
        match_list.extend(re.findall(regex, files_data, re.MULTILINE))
    return convert(match_list)


def get_completion_words():
    files_data = ""
    for path in args.add:
        with open(pathlib.Path(path)) as file:
            files_data += file.read()
    word_list = []
    regexes = []
    regexes.extend(args.regex)
    regexes.extend(REGEXES_L)
    for regex in regexes:
        files_data = re.sub(regex, " ", files_data)
    word_list.append(files_data)
    return convert(word_list)


def run():
    filter.add_to_completion_list(*get_completion_words())
    filter.remove_from_completion_list(*get_blacklisted_words())
    filter.run()  # from this function we never return (inf loop)


def threads():
    filter_thread = Thread(target=run, daemon=True)
    ppid_thread = Thread(target=kill, daemon=True)
    filter_thread.start()
    ppid_thread.start()
    filter_thread.join()
    ppid_thread.join()


threads()
