#!/usr/bin/env bash
#
# Manages drives for a kvm/qemu virtual machine. Requires the nbd kernel module

TARGET_DIR="/mnt/temp"

echof() {
	local prefix="$1"
	local message="$2"
	case "$prefix" in
	header) msgpfx="[\e[1;95m\e[m]" ;;
	info) msgpfx="[\e[1;97m=\e[m]" ;;
	act) msgpfx="[\e[1;92m*\e[m]" ;;
	ok) msgpfx="[\e[1;93m+\e[m]" ;;
	error) msgpfx="[\e[1;91m!\e[m]" ;;
	*) msgpfx="" ;;
	esac
	echo -e "$msgpfx $message"
}

check_if_sudo() {
	[[ "$EUID" -ne 0 ]] && echof error "Not running as a root user!" >&2 && exit 1
}

ensure_available() {
	command -v "${1}" >/dev/null 2>&1 || {
		echof error "${1} isn't available!" >&2
		exit 1
	}
}

check_if_available() {
	echof info "Checking if the target directory is not empty"
	[[ "$(ls -A $TARGET_DIR)" ]] && echof error "The target directory ${TARGET_DIR} is not empty!" >&2 && exit 1
}

main() {
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
		check_if_available
		echof info "Mounting ${mount_source} on ${TARGET_DIR}"
		modprobe nbd max_part=8
		qemu-nbd --connect=/dev/nbd0 "${mount_source}"
		mount "/dev/nbd0p${partition_num}" "${TARGET_DIR}"
		echof info "Successfully mounted"
	elif [[ "$action" == "disconnect" ]]; then
		echof info "Unmounting ${mount_source} from ${TARGET_DIR}"
		umount "${TARGET_DIR}"
		qemu-nbd --disconnect /dev/nbd0 >>/dev/null
		rmmod nbd
		echof info "Successfully unmounted"
	else
		echof error "Unsupported action" >&2 && exit 1
	fi
}

check_if_sudo
ensure_available "qemu-x86_64"

main "$*"
