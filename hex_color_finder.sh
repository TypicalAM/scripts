#!/usr/bin/env bash
#
# Takes the average pixel value of a rectangular area and copies
# the hex code of the color to the clipboard

ensure_available() {
	command -v "${1}" >/dev/null 2>&1 || {
		echo -e "[\e[1;91m!\e[m] ${1} isn't available!" >&2
		exit 1
	}
}

main() {
	local file="$(mktemp).png"
	local hex_value=$(maim -s | convert - -scale 1x1\! -format '%[fx:int(255*r+.5)],%[fx:int(255*g+.5)],%[fx:int(255*b+.5)]' info:- | sed 's/,/\n/g' | xargs -L 1 printf "%x")
	convert -size 48x48 "xc:#${hex_value}" "$file"
	notify-send "This is your color!" "#${hex_value} copied to clipboard" -i "$file"
	echo "#${hex_value}" | tr "\n" " " | xclip -selection clipboard
}

ensure_available "maim"
ensure_available "xclip"
ensure_available "notify-send"

main
