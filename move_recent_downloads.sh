#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# Move the most recent downloaded file into the current working directory
# or, if specified - to another directory

main() {
	if [[ ! "$*" = "" ]] ; then
 		target_dir=$*
	else
		target_dir=$PWD
	fi
	file=$(ls -t1 $HOME/downloads |head -n 1)
	[[ -f "$file" ]] && exit 1
	mv "$HOME/downloads/$file" "$target_dir" && notify-send "Moved $file to $mv_dir"
}

main
