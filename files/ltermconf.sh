#!/bin/bash

PATH="/bin:usr/bin"

i=0

while [ $i -lt 45 ]; do
  cat default.conf | sed "s#^background_image.*#background_image = /home/${1}/wallpaper/resized${i}.jpg#" > lilyterm${i}.conf
  i=$(($i+1))
done
