#!/usr/bin/env bash
#
# Opens the nvim todo list in the most recent kitty window

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
}

ensure_available "kitty"

main
