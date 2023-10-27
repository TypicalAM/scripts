#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# Wrap rofi in an nvidia_offload environment

export __NV_PRIME_RENDER_OFFLOAD=1
export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __VK_LAYER_NV_optimus=NVIDIA_only
rofi -no-lazy-grab -show drun -modi drun -theme ~/.config/rofi/default.rasi
