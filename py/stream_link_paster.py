#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Main module."""
import pyperclip
import subprocess


def main():
    streamlink = "streamlink "
    streamurl = "empty"
    quality = "720p"
    result = ""

    streamurl = pyperclip.paste()
    result = streamlink + streamurl + " " + quality

    subprocess.call(result)


main()
