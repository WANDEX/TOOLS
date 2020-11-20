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

filter = rlwrapfilter.RlwrapFilter()

filter.help_text = "Usage: rlwrap [-options] -z ] remove_from_completion.py <command>\n"\
                   + " remove from completion list"


def convert(lst):
    return tuple(set(' '.join(lst).split()))


parser = argparse.ArgumentParser()
parser.add_argument('--file', '-f', type=str, action='append', help="path to file.", required=True)
parser.add_argument('--regex', '-r', type=str, action='append', help="match regex to exclude", required=True)
args = parser.parse_args()

files_data = ""
for path in args.file:
    with open(pathlib.Path(path)) as file:
        files_data += file.read()

match = []
for regex in args.regex:
    match.extend(re.findall(regex, files_data, re.MULTILINE))

blacklist = convert(match)

filter.remove_from_completion_list(*blacklist)

filter.run()
