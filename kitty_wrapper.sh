#!/usr/bin/env bash
#
# Wraps the existing `kitty` terminal emulator and allows for remote control of every kitty window

ensure_available() {
	command -v "${1}" >/dev/null 2>&1 || {
		echo -e "[\e[1;91m!\e[m] ${1} isn't available!" >&2
		exit 1
	}
}

main() {
	local highest_number=0
	local highest_filename=""

	for file in /tmp/kitty_dev*; do
		local number="${file##*_dev}"
		if ((number > highest_number)); then
			highest_number="$number"
			highest_filename="$file"
		fi
	done

	if [ -n "$highest_filename" ]; then
		echo "Listening on: $((highest_number + 1))"
		kitty -o allow_remote_control=yes --listen-on unix:/tmp/kitty_dev$((highest_number + 1)) -- "$@"
	else
		echo "No matching files found. Listening on: 1"
		kitty -o allow_remote_control=yes --listen-on unix:/tmp/kitty_dev1 -- "$@"
	fi
}

ensure_available "kitty"

main $*
