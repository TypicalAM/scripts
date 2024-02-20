#!/usr/bin/env bash
#
# Move the most recent downloaded file into the current working directory
# or, if specified - to another directory

DOWNLOADS_DIR="$HOME/downloads"

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

main() {
	local target_dir
	if [[ ! "$*" = "" ]]; then
		target_dir="$*"
	else
		target_dir=$PWD
	fi
	local filename=$(ls -t1 "$DOWNLOADS_DIR" | head -n 1)
	echof info "Newest filename: $filename"
	if [[ -f "$DOWNLOADS_DIR/$filename" ]]; then
		echof error "There is no newest file, damn" >&2
		exit 1
	else
		mv "$DOWNLOADS_DIR/$filename" "$target_dir"
		echof info "Moved file to $target_dir" >&2
	fi
}

main "$*"
