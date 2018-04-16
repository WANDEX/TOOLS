#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Main module."""
import codecs


file = input("file name in current directory: ")
if (file.isspace() or file == ""):
    raise ValueError("A FILE WAS NOT PROVIDED")

output = input("output name: ")
if (output.isspace() or output == ""):
    output = "new_" + str(file)

encoding = input("encoding, by default is 'UTF-8': ") or "utf-8"

print(str(file + " " + output + " " + encoding))

with codecs.open(file, 'r', encoding, errors='replace') as f_in, codecs.open(output, 'w', encoding) as f_out:
    f_out.writelines(reversed(f_in.readlines()))
    print("SUCCESS")
