#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# A bash script to wrap the existing `kitty` terminal emulator and allow for remote control of every kitty window

highest_number=0
highest_filename=""

for file in /tmp/kitty_dev*; do
	number="${file##*_dev}"
	if ((number > highest_number)); then
  	highest_number="$number"
    highest_filename="$file"
  fi
done

if [ -n "$highest_filename" ]; then
	echo "Listening on: $((highest_number+1))"
	kitty -o allow_remote_control=yes --listen-on unix:/tmp/kitty_dev$((highest_number+1))
else
  echo "No matching files found. Listening on: 1"
	kitty -o allow_remote_control=yes --listen-on unix:/tmp/kitty_dev1
fi
