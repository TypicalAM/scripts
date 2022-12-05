#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# A small script to hibernate the device if the battery is below a certiain threshhold
# It is made for use in crontab, with an example rule being '* * * * * /home/test/script/battery.sh'

[[ ! -f /usr/local/bin/betterlockscreen ]] && echo "no betterlockscreen" && exit 1
[[ ! -f /bin/notify-send ]] && echo "no notify-send" && exit 1
[[ ! -f /bin/acpi ]] && echo "no acpi" && exit 1

check_battery_status() {
	local mode="$1"
	local battery_status="$(acpi -b)"
	local percentage="$(echo $battery_status | grep -P -o '[0-9]+(?=%)')"

	if echo $battery_status | grep Discharging > /dev/null && [[ "$percentage" -le 5 ]]; then
		if [[ "$mode" == "first" ]]; then
    	notify-send "Battery low" "Hibernating in 30 seconds"
			sleep 30
		else
			betterlockscreen -l & sleep 0.5 && systemctl hibernate
		fi
	else
		exit 0
	fi
}

check_battery_status "first" && check_battery_status "second"
