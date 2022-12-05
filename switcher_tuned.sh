#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# A script to switch the CPU profiles via the tuned switcher

ROFI_COMMAND="rofi -dmenu -i -p Power -theme ~/.config/rofi/default_no_icons.rasi"
ICON="/usr/share/icons/McMojave-circle-purple/status/32/system-switch-user.svg"
OPTIONS="accelerator-performance\nbalanced\ndesktop\nhpc-compute\nintel-sst\nlatency-performance\nnetwork-latency\nnetwork-throughput\noptimize-serial-console\npowersave\nthroughput-performance\nvirtual-guest\nvirtual-host"

ensure_available() {
	local program_path="$1"
	[[ ! -f "$program_path" ]] && echo -e "[\e[1;91m!\e[m] ${program_path} isn't available!" >&2 && exit 1
}

main() {
	local chosen=$(echo -e "$OPTIONS"|$ROFI_COMMAND)
	if tuned-adm profile "$chosen"; then
		notify-send "Power mode changed" "Current mode: $chosen" -i $ICON
	else
		notify-send "Power mode change failed" "Failed changing to: $chosen" -i $ICON
	fi
}

ensure_available "/usr/sbin/tuned-adm"
ensure_available "/bin/notify-send"
ensure_available "/bin/rofi"
main
