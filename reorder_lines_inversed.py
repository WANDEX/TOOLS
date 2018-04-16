#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Main module."""
import codecs

file = "file.txt"
output = "output_file.txt"

file = input("file name in current directory:\n")
output = input("output name:\n")
if(output.isspace() or output == str("")):
    output = "new_" + str(file)
print(str(file + " " + output))

with codecs.open(file, encoding='utf-8', errors='replace') as f_in, open(output, 'w') as f_out:
    f_out.writelines(reversed(f_in.readlines()))
    f_out.write(u'\ufeff')
    f_out.close()
    print("SUCCESS")
