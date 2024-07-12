#!/usr/bin/env bash
#
# Hibernates if it is safe to do so

ICON="$HOME/.icons/McMojave-circle/status/32/security-medium.svg"

ensure_available() {
	command -v "${1}" >/dev/null 2>&1 || {
		echo -e "[\e[1;91m!\e[m] ${1} isn't available!" >&2
		exit 1
	}
}

main() {
	if virsh list | grep win; then
		notify-send "Cannot hibernate" "There is a windows virtual machine running right now" -i "$ICON"
	else
		betterlockscreen -l &
		sleep 0.5 && systemctl hibernate
	fi
}

ensure_available "notify-send"
ensure_available "virsh"
ensure_available "betterlockscreen"

main
