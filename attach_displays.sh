#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# A script intended to make switching between laptop and external displays easier
# Check your internal output value with xrandr | grep " connected" | cut -f1 -d " "

INTERNAL_OUTPUT="eDP"
ROFI_COMMAND="rofi -dmenu -i -p Output -theme ~/.config/rofi/default_no_icons.rasi"
CHOICES="Laptop\nDual\nExternal\nClone"
POSSIBLE_DISPLAYS=("VGA-1" "DVI-1" "HDMI-0" "HDMI-1" "HDMI-2" "HDMI-3" "HDMI-1-0")

ensure_available() {
	local program_path="$1"
	[[ ! -f "$program_path" ]] && echo -e "[\e[1;91m!\e[m] ${program_path} isn't available!" >&2 && exit 1
}
                                                                                                                                                                                                                                                               
determine_external() {
	for possible_display in "${POSSIBLE_DISPLAYS[@]}"; do
		[[ $(xrandr | grep "$possible_display" | grep -c ' connected ') -eq 1 ]] && external_output="$possible_display"
	done
}

run_xrandr() {
	case "$1" in
 		External) xrandr --output $INTERNAL_OUTPUT --off --output "$external_output" --auto --primary ;;
    Laptop) xrandr --output $INTERNAL_OUTPUT --auto --primary --output "$external_output" --off ;;
    Clone) xrandr --output $INTERNAL_OUTPUT --auto --output "$external_output" --auto --same-as $INTERNAL_OUTPUT ;;
    Dual) xrandr --output $INTERNAL_OUTPUT --auto --output "$external_output" --auto --above $INTERNAL_OUTPUT --primary ;;
	esac
}

ensure_available "/bin/xrandr"
ensure_available "/bin/rofi"
ensure_available "/bin/notify-send"

chosen=$(echo -e $CHOICES | $ROFI_COMMAND)  
determine_external
run_xrandr "$chosen"
