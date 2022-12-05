#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# A script to detach and reattach drives for a kvm/qemu virtual machine 

TARGET_DIR="/mnt/temp"

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

check_if_sudo() {
	[[ "$EUID" -ne 0 ]] && echof error "Not running as a root user!" >&2 && exit 1
}

ensure_available() {
	[[ ! -f "$1" ]] && echof error "$1 isn't available!" >&2 && exit 1
}

parse_cmd() {
	[[ "$1" == "" ]] || [[ "$2" == "" ]] && echof error "Not enough arguments given!" >&2 && exit 1

	local action="$1"
	local device="$2"

	if [[ "$device" == "arch" ]]; then
		mount_source="/opt/virtualization/images/archlinux.qcow2"
		partition_num="3"
	else
		echof error "We do not support other machines at this time" >&2 && exit 1
	fi

	if [[ "$action" == "connect" ]]; then
		run_connect=true
	elif [[ "$action" == "disconnect" ]]; then
		run_disconnect=true
	else
		echof error "Unsupported action" >&2 && exit 1
	fi
}

check_if_available() {
	echof info "Checking if the target directory is not empty"
	[[ "$(ls -A $TARGET_DIR)" ]] && echof error "The target directory ${TARGET_DIR} is not empty!" >&2 && exit 1
}

connect() {
	check_if_available
	echof info "Mounting ${mount_source} on ${TARGET_DIR}"
	modprobe nbd max_part=8
	qemu-nbd --connect=/dev/nbd0 "${mount_source}"
	mount "/dev/nbd0p${partition_num}" "${TARGET_DIR}"
	echof info "Successfully mounted"
}

disconnect() {
	echof info "Unmounting ${mount_source} from ${TARGET_DIR}"
	umount "${TARGET_DIR}"
	qemu-nbd --disconnect /dev/nbd0 >> /dev/null
	rmmod nbd
	echof info "Successfully unmounted"
}

check_if_sudo
ensure_available "/bin/qemu-x86_64"
parse_cmd "$1" "$2"

[[ $run_connect ]] && connect
[[ $run_disconnect ]] && disconnect
