#!/usr/bin/env bash

echo
function main() {
	# Local variables to hold the arguments
	state=$1
	name=$2
	ver=$4
	rel=$5
	arch=$6

	# Check if this just the real kernel package
	[[ "$name" != "kernel" ]] && exit 0

	# Exit if we aren't installing
	[[ "$state" != "install" ]] && [[ "$state" != "reinstall" ]] && exit 0

	# Kernel and initramfs names are in the following format
	# vmlinuz-6.9.6-200.fc40.x86_64 - vmlinuz-$ver-$rel.$arch
	# initramfs-6.9.6-200.fc40.x86_64.img - initramfs-$ver-$rel.$arch.img
	local kernel_file initramfs_file
	kernel_file="/boot/vmlinuz-$ver-$rel.$arch"
	initramfs_file="/boot/initramfs-$ver-$rel.$arch.img"

	[[ ! -f "$kernel_file" ]] && echo "[hook] vmlinuz file missing" && exit 1
	[[ ! -f "$initramfs_file" ]] && echo "[hook] initramfs file missing" && exit 1

	# EFI should be in ESP:/EFI/fedora, for example /efi/EFI/fedora or /boot/efi/EFI/fedora
	local boot_dir filename_suffix
	boot_dir="/boot/efi/EFI/fedora"
	filename_suffix=own-fedora
	[[ ! -d $boot_dir ]] && echo "[hook] /boot/efi/EFI/fedora missing" && exit 1

	if cp "$kernel_file" $boot_dir/vmlinuz-$filename_suffix; then
		echo "[hook] copied kernel to $boot_dir/vmlinuz-$filename_suffix"
	else
		echo "[hook] failed copying $kernel_file to $boot_dir/vmlinuz-$filename_suffix" && exit 1
	fi

	if cp "$initramfs_file" $boot_dir/initramfs-$filename_suffix.img; then
		echo "[hook] copied initramfs to $boot_dir/initramfs-$filename_suffix.img"
	else
		echo "[hook] failed copying $initramfs_file to $boot_dir/initramfs-$filename_suffix.img" && exit 1
	fi
}

main $*
