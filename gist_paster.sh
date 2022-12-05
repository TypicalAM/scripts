#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# This script allows for pasting the clipboard contents to a github gist
# and replacing the clipboard contents with the resulting URL

ROFI_COMMAND="rofi -dmenu -i -p Filename -theme ~/.config/rofi/default_no_icons_small.rasi"
ICON="/usr/share/icons/McMojave-circle-purple/status/32/dialog-information.svg"
EXAMPLE_NAMES="script.sh\ndocument.md\nprogram.c\ntest.py\ntest.go"

ensure_available() {
	local program_path="$1"
	[[ ! -f "$program_path" ]] && echo -e "[\e[1;91m!\e[m] ${program_path} isn't available!" >&2 && exit 1
}

paste_gist() {
	local chosen_name=$(echo -e "$EXAMPLE_NAMES" | $ROFI_COMMAND)
	[[ "$chosen_name" == "" ]] && exit 0
	xclip -selection clipboard -o > "/tmp/${chosen_name}"
	local output=$(gist "/tmp/${chosen_name}")
	notify-send "Gist has been saved" "It is available at $output" -i $ICON
	echo "$output" | xclip -selection clipboard
}

ensure_available "/bin/gist"
ensure_available "/bin/xclip"
ensure_available "/bin/rofi"
paste_gist
