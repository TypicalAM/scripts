#!/usr/bin/env bash
#
# Pastes the clipboard contents to a github gist and replaces the
# clipboard contents with the resulting URL

ROFI_COMMAND="rofi -dmenu -i -theme ~/.config/rofi/default_no_icons_small.rasi"
ICON="/usr/share/icons/McMojave-circle-purple/status/32/dialog-information.svg"
EXAMPLE_NAMES="script.sh\ndocument.md\nprogram.c\ntest.py\ntest.go"
EXAMPLE_DESCRIPTIONS="Shared with <3 by Adam\nKod"

ensure_available() {
	command -v "${1}" >/dev/null 2>&1 || {
		echo -e "[\e[1;91m!\e[m] ${1} isn't available!" >&2
		exit 1
	}
}

paste_gist() {
	local chosen_name
	chosen_name="$(echo -e "${EXAMPLE_NAMES}" | ${ROFI_COMMAND} -p Filename)"
	[[ "$chosen_name" == "" ]] && exit 0
	xclip -selection clipboard -o >"/tmp/${chosen_name}"

	local description
	description="$(echo -e "${EXAMPLE_DESCRIPTIONS}" | ${ROFI_COMMAND} -p Description)"

	local output
	output=$(gist --private --description "${description}" "/tmp/${chosen_name}")
	notify-send "Gist has been saved" "It is available at $output" -i $ICON
	echo "$output" | xclip -selection clipboard
}

ensure_available "gist"
ensure_available "xclip"
ensure_available "rofi"

paste_gist
