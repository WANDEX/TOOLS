#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Main module."""
file = "file.txt"
output = "output_file.txt"

file = input("file name in current directory:\n")
output = input("output name:\n")
if(output.isspace() or output == str("")):
    output = "new_" + str(file)
print(str(file + " " + output))

with open(file) as f_in, open(output, 'w') as f_out:
    f_out.writelines(reversed(f_in.readlines()))
