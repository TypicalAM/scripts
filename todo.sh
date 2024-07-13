#!/usr/bin/env bash
#
# Opens the nvim todo list

ensure_available() {
	command -v "${1}" >/dev/null 2>&1 || {
		echo -e "[\e[1;91m!\e[m] ${1} isn't available!" >&2
		exit 1
	}
}

main() {
	i3-msg exec 'kitty -- nvim /home/adam/notes/luzne\ notatki/todo.md'
	sleep 0.3
	i3-msg resize shrink width 30 px or 30 ppt
}

ensure_available "kitty"
ensure_available "i3-msg"

main
