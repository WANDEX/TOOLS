#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import socket
import socks
import requests

socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 9150)
socket.socket = socks.socksocket
r = requests.get("http://icanhazip.com")
print(r.content)
