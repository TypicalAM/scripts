#!/usr/bin/env bash
#
# Rotates the sceren 180° (yes)

ensure_available() {
	command -v "${1}" >/dev/null 2>&1 || {
		echo -e "[\e[1;91m!\e[m] ${1} isn't available!" >&2
		exit 1
	}
}

main() {
	local monitor="$(xrandr --query --verbose | grep ' connected' | cut -d ' ' -f 1)"
	if [ "$(xrandr --query --verbose | grep ' connected' | grep -o normal | wc -l)" -eq "2" ]; then
		xrandr --output "$monitor" --rotate inverted
	else
		xrandr --output "$monitor" --rotate normal
	fi
}

ensure_available "xrandr"

main
