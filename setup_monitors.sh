#!/usr/bin/bash
#
# Sets the main monitor as the secondary one when booting

if [ "$(xrandr -q | grep " connected " | cut -d' ' -f1 | wc -l)" == 2 ]; then
	xrandr \
		--output eDP --off --output DP-1-0 --off \
		--output DP-1-1 --off \
		--output HDMI-1-0 --mode 1920x1080 --pos 0x0 --rotate normal \
		--output DP-1-2 --off
fi
