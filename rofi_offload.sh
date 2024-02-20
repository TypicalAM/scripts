#!/usr/bin/env bash
#
# Wraps rofi to launch a dedicated GPU app

ROFI_COMMAND="rofi -no-lazy-grab -show drun -modi drun -theme ~/.config/rofi/default.rasi"

ensure_available() {
	command -v "${1}" >/dev/null 2>&1 || {
		echo -e "[\e[1;91m!\e[m] ${1} isn't available!" >&2
		exit 1
	}
}

main() {
	export __NV_PRIME_RENDER_OFFLOAD=1
	export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
	export __GLX_VENDOR_LIBRARY_NAME=nvidia
	export __VK_LAYER_NV_optimus=NVIDIA_only
	$ROFI_COMMAND
}

ensure_available "rofi"

main
