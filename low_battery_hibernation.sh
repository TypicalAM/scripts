#!/usr/bin/env bash
#
# Hibernates the device if the battery is below a certiain threshhold, for use in cronjobs

ensure_available() {
	command -v "${1}" >/dev/null 2>&1 || {
		echo -e "[\e[1;91m!\e[m] ${1} isn't available!" >&2
		exit 1
	}
}

check_battery_status() {
	local mode="$1"
	local battery_status="$(acpi -b)"
	local percentage="$(echo $battery_status | grep -P -o '[0-9]+(?=%)')"

	if echo "$battery_status" | grep Discharging >/dev/null && [[ "$percentage" -le 5 ]]; then
		if [[ "$mode" == "first" ]]; then
			notify-send "Battery low" "Hibernating in 30 seconds"
			sleep 30
		else
			betterlockscreen -l &
			sleep 0.5 && systemctl hibernate
		fi
	else
		exit 0
	fi
}

ensure_available "betterlockscreen"
ensure_available "notify-send"
ensure_available "acpi"

check_battery_status "first" && check_battery_status "second"
