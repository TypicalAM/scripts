#!/usr/bin/env bash
#
# Makes password management easier - print out all the available passwords from pass
# and select them from rofi

ROFI_COMMAND="rofi -dmenu -i -p Passwords -theme $HOME/.config/rofi/default_no_icons.rasi"

ensure_available() {
	command -v "${1}" >/dev/null 2>&1 || {
		echo -e "[\e[1;91m!\e[m] ${1} isn't available!" >&2
		exit 1
	}
}

main() {
	shopt -s nullglob globstar
	local prefix=${PASSWORD_STORE_DIR-~/.password-store}
	local password_files=("$prefix"/**/*.gpg)
	password_files=("${password_files[@]#"$prefix"/}")
	password_files=("${password_files[@]%.gpg}")
	local password=$(printf '%s\n' "${password_files[@]}" | $ROFI_COMMAND)
	[[ -n $password ]] || exit 1
	pass show -c "$password" | head -n1 2>/dev/null
	notify-send -t 1500 'Copied to clipboard'
}

ensure_available "pass"
ensure_available "rofi"
ensure_available "notify-send"

main "$@"
