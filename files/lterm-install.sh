#!/bin/bash
#
# download and install lilyterm
#
curl -o /usr/local/src/lilyterm-0.9.9.2.tar.gz https://lilyterm.luna.com.tw/file/lilyterm-0.9.9.2.tar.gz
tar -C /usr/local/src -zvxf /usr/local/src/lilyterm-0.9.9.2.tar.gz 
cd /usr/local/src/lilyterm-0.9.9.2
./configure
make
make install
