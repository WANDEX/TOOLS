#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Main module."""
import codecs
from os import path


file = input("file name in current directory or full path to file with extension: \n")

assert path.exists(file), "THE PROVIDED FILE OR DIRECTORY DOES NOT EXIST AT,\n" + str(file)

if (file.isspace() or file == ""):
    raise ValueError("PROPER FILE NAME WAS NOT PROVIDED")

output = input("output name: ")

if (output.isspace() or output == ""):
    pair = path.splitext(file)
    output = pair[0] + "_new" + pair[1]

encoding = input("encoding, by default is 'UTF-8': ") or "utf-8"

print(str(file + " " + output + " " + encoding))

with codecs.open(file, 'r', encoding, errors='replace') as f_in, codecs.open(output, 'w', encoding) as f_out:
    f_out.writelines(reversed(f_in.readlines()))
    print("SUCCESS")
