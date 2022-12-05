#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# A script to rotate the sceren 180°

ensure_available() {
	local program_path="$1"
	[[ ! -f "$program_path" ]] && echo -e "[\e[1;91m!\e[m] ${program_path} isn't available!" >&2 && exit 1
}

main() {
	local monitor="$(xrandr --query --verbose | grep ' connected'|cut -d ' ' -f 1)"
	if [ "$(xrandr --query --verbose | grep ' connected'|grep -o normal |wc -l)" -eq "2" ]
		then xrandr --output $monitor --rotate inverted
		else xrandr --output $monitor --rotate normal
	fi
}

ensure_available "/bin/xrandr"
main
