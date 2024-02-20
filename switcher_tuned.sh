#!/usr/bin/env bash
#
# Switches the CPU profiles via tuned switcher

ROFI_COMMAND="rofi -dmenu -i -p Power -theme ~/.config/rofi/default_no_icons.rasi"
ICON="/usr/share/icons/McMojave-circle-purple/status/32/system-switch-user.svg"
OPTIONS="accelerator-performance\nbalanced\ndesktop\nhpc-compute\nintel-sst\nlatency-performance\nnetwork-latency\nnetwork-throughput\noptimize-serial-console\npowersave\nthroughput-performance\nvirtual-guest\nvirtual-host"

ensure_available() {
	command -v "${1}" >/dev/null 2>&1 || {
		echo -e "[\e[1;91m!\e[m] ${1} isn't available!" >&2
		exit 1
	}
}

main() {
	local chosen=$(echo -e "$OPTIONS" | $ROFI_COMMAND)
	[[ -n $chosen ]] || exit 1
	if tuned-adm profile "$chosen"; then
		notify-send "Power mode changed" "Current mode: $chosen" -i $ICON
	else
		notify-send "Power mode change failed" "Failed changing to: $chosen" -i $ICON
	fi
}

ensure_available "tuned-adm"
ensure_available "notify-send"
ensure_available "rofi"

main
