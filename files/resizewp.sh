#!/bin/bash

PATH='/bin:/usr/bin'

convert '*.jpg['$1'x]' resized%d.jpg
