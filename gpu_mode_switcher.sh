#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# A bash script to set the GPU mode using supergfxctl

ICON="/usr/share/icons/McMojave-circle-purple/status/32/system-switch-user.svg"
MODES="Integrated\nHybrid\nDedicated\nCompute\nVfio"
ROFI_THEME="~/.config/rofi/default_no_icons.rasi"

echof() {
	local colorReset="\033[0m"
	local prefix="$1"
	local message="$2"

	case "$prefix" in
		header) msgpfx="[\e[1;95mG\e[m]" color="";;
		info) msgpfx="[\e[1;92m*\e[m]" color="";;
		error) msgpfx="[\e[1;91m!\e[m]" color="\033[0;31m";;
		*) msgpfx="" color="";;
	esac
	echo -e "$msgpfx $color$message $colorReset"
}

ensure_available() {
	local program_path="$1"
	[[ ! -f "$program_path" ]] && echof error "${program_path} isn't available!" >&2 && exit 1
}

main(){
	ROFI_COMMAND="rofi -dmenu -i -p $(supergfxctl -g) -theme $ROFI_THEME"
	CHOSEN_MODE=$(echo -e "$MODES"|$ROFI_COMMAND)
	[[ "$CHOSEN_MODE" == "" ]] && echof error "Operation cancelled" && exit 1
	[[ "$CHOSEN_MODE" == "Vfio" ]] && [[ "$(supergfxctl -g)" != "Integrated" ]] && notify-send "Failed to switch the mode" "Can't switch from non-integrated to vfio" && exit 1
	echof info "Chosen mode: $CHOSEN_MODE"
	if supergfxctl -m $CHOSEN_MODE > /dev/null; then
		echof info "Mode switched to $CHOSEN_MODE, you now have to log off"
		notify-send "GPU mode changed to $CHOSEN_MODE" "Log out to see the changes" -i $ICON
	else
		echof error "Failed to switch the mode"
		notify-send "GPU mode change failed" "Check out the log for details" -i $ICON
	fi
}

ensure_available "/bin/supergfxctl"
ensure_available "/bin/rofi"
ensure_available "/bin/notify-send"
main
