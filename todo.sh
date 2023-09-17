#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# A bash script to open the nvim todo list in the most recent kitty window

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
	base_command="kitty @ --to unix:$highest_filename"
	$base_command launch --type tab
	$base_command send-text nvim \\x0d
	$base_command send-text t\\x0d
fi
