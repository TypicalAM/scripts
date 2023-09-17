#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# A script to take the average pixel value of a rectangular area
# and copy the hex code of the color to the clipboard

ensure_available() {
	local program_path="$1"
	[[ ! -f "$program_path" ]] && echo -e "[\e[1;91m!\e[m] ${program_path} isn't available!" >&2 && exit 1
}

main() {
	local file="$(mktemp).png"
	local hex_value=$(maim -s |convert - -scale 1x1\! -format '%[fx:int(255*r+.5)],%[fx:int(255*g+.5)],%[fx:int(255*b+.5)]' info:- | sed 's/,/\n/g' | xargs -L 1 printf "%x")
	convert -size 48x48 xc:#$hex_value $file
	notify-send "This is your color!" "#$hex_value copied to clipboard" -i $file
	echo "#$hex_value" | tr "\n" " " | xclip -selection clipboard
}

ensure_available "/bin/maim"
ensure_available "/bin/xclip"
ensure_available "/bin/notify-send"
main
