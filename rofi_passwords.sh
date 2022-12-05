#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# A script to make password management easier - with pass and rofi
# we can print out all the available passwords in the vault and make the user
# choose one of them in the rofi menu - then they can get the password right to
# their clipboard!

ensure_available() {
	local program_path="$1"
	[[ ! -f "$program_path" ]] && echo -e "[\e[1;91m!\e[m] ${program_path} isn't available!" >&2 && exit 1
}

main() {
	shopt -s nullglob globstar
	prefix=${PASSWORD_STORE_DIR-~/.password-store}
	password_files=( "$prefix"/**/*.gpg )
	password_files=( "${password_files[@]#"$prefix"/}" )
	password_files=( "${password_files[@]%.gpg}" )
	password=$(printf '%s\n' "${password_files[@]}" | rofi -dmenu "$@" -i -p "Passwords" -theme $HOME/.config/rofi/default_no_icons.rasi)
	[[ -n $password ]] || exit
	pass show -c "$password" | head -n1  2>/dev/null
	notify-send -t 1500 'Copied to clipboard'
}

ensure_available "/bin/pass"
ensure_available "/bin/rofi"
ensure_available "/bin/notify-send"
main
