#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# A script to set the next OS to Windows (on refind)

ICON="/usr/share/icons/McMojave-circle-purple/status/32/system-switch-user.svg"

ensure_available() {
	local program_path="$1"
	[[ ! -f "$program_path" ]] && echo -e "[\e[1;91m!\e[m] ${program_path} isn't available!" >&2 && exit 1
}

ensure_writable() {
	[[ ! -d "$1" ]] || [[ ! -w "$1" ]] && echo -e "[\e[1;91m!\e[m] ${1} isn't writable!" >&2 && exit 1
}

main() {
	if [[ "$1" == "Windows" ]]; then
		echo "default_selection 1" > /boot/efi/EFI/refind/next_boot.conf
		sudo -u adam notify-send "Next os changed" "Current mode: Windows" -i $ICON
	else
		echo "default_selection 2" > /boot/efi/EFI/refind/next_boot.conf
	fi
}

ensure_writable "/boot/efi/EFI/refind"
ensure_available "/bin/notify-send"
main $1
