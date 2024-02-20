#!/usr/bin/env bash
#
# Sets the GPU mode using supergfxctl

ICON="/usr/share/icons/McMojave-circle-purple/status/32/system-switch-user.svg"
MODES="Integrated\nHybrid\nDedicated\nCompute\nVfio"
ROFI_THEME="$HOME/.config/rofi/default_no_icons.rasi"

echof() {
	local colorReset="\033[0m"
	local prefix="$1"
	local message="$2"

	case "$prefix" in
	header) msgpfx="[\e[1;95mG\e[m]" color="" ;;
	info) msgpfx="[\e[1;92m*\e[m]" color="" ;;
	error) msgpfx="[\e[1;91m!\e[m]" color="\033[0;31m" ;;
	*) msgpfx="" color="" ;;
	esac
	echo -e "$msgpfx $color$message $colorReset"
}

ensure_available() {
	command -v "${1}" >/dev/null 2>&1 || {
		echo -e "[\e[1;91m!\e[m] ${1} isn't available!" >&2
		exit 1
	}
}

main() {
	local rofi_command="rofi -dmenu -i -p $(supergfxctl -g) -theme $ROFI_THEME"
	local chosen_mode=$(echo -e "$MODES" | $rofi_command)
	[[ "$chosen_mode" == "" ]] && echof error "Operation cancelled" && exit 1
	[[ "$chosen_mode" == "Vfio" ]] && [[ "$(supergfxctl -g)" != "Integrated" ]] && notify-send "Failed to switch the mode" "Can't switch from non-integrated to vfio" && exit 1
	echof info "Chosen mode: $chosen_mode"
	if supergfxctl -m "$chosen_mode" >/dev/null; then
		echof info "Mode switched to $chosen_mode, you now have to log off"
		notify-send "GPU mode changed to $chosen_mode" "Log out to see the changes" -i $ICON
	else
		echof error "Failed to switch the mode"
		notify-send "GPU mode change failed" "Check out the log for details" -i $ICON
	fi
}

ensure_available "supergfxctl"
ensure_available "rofi"
ensure_available "notify-send"

main
