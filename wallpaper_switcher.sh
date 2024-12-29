#!/usr/bin/env bash
#
# Changes the wallpaper and makes theme colors based on the chosen wallpaper

echof() {
	local colorReset="\033[0m"
	local prefix="$1"
	local message="$2"
	case "$prefix" in
	header) msgpfx="[\e[1;95mW\e[m]" color="" ;;
	act) msgpfx="[\e[1;97m=\e[m]" color="\033[0;34m" ;;
	info) msgpfx="[\e[1;92m*\e[m]" color="" ;;
	ok) msgpfx="[\e[1;93m+\e[m]" color="\033[0;32m" ;;
	error) msgpfx="[\e[1;91m!\e[m]" color="\033[0;31m" ;;
	*) msgpfx="" color="" ;;
	esac
	echo -e "$msgpfx$color $message $colorReset"
}

set_home_dir() {
	if [[ $EUID -eq 0 ]]; then
		USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
	else
		USER_HOME=$HOME
	fi
}

init_config() {
	POLYBAR_COLORS="$USER_HOME/.config/polybar/theme/colors.ini"
	ROFI_COLORS="$USER_HOME/.config/rofi/colors.rasi"
	KITTY_COLORS="$USER_HOME/.config/kitty/theme.conf"
	DUNST_COLORS="$USER_HOME/.config/dunst/dunstrc"
	ZATHURA_FOLDER="$USER_HOME/.config/zathura"
	SDDM_BACKGROUND="/usr/share/sddm/themes/plasma-chili/components/artwork/background.jpg"

	WALLPAPER_DIR="$USER_HOME/pictures/wallpapers"
	ROFI_COMMAND="rofi -dmenu -i -p Wallpaper -theme $USER_HOME/.config/rofi/default_no_icons.rasi"
}

check_features() {
	command -v "polybar" >/dev/null 2>&1 && [[ -w "$POLYBAR_COLORS" ]] && run_polybar=true
	command -v "rofi" >/dev/null 2>&1 && [[ -w "$ROFI_COLORS" ]] && run_rofi=true
	command -v "kitty" >/dev/null 2>&1 && [[ -w "$KITTY_COLORS" ]] && run_kitty=true
	command -v "dunst" >/dev/null 2>&1 && [[ -w "$DUNST_COLORS" ]] && run_dunst=true
	command -v "zathura" >/dev/null 2>&1 && [[ -w "$ZATHURA_FOLDER" ]] && run_zathura=true
	command -v "sddm" >/dev/null 2>&1 && [[ -w "$SDDM_BACKGROUND" ]] && run_sddm=true
	command -v "pywalfox" >/dev/null 2>&1 && run_pywalfox=true
	command -v "betterlockscreen" >/dev/null 2>&1 && run_betterlockscreen=true
}

get_colors() {
	echof info "Getting colors from image"
	wal --saturate 0.3 -i "$1" -q -t
	source "$USER_HOME/.cache/wal/colors.sh"
	BG=$(printf "%s\n" "$background")
	FG=$(printf "%s\n" "$color0")
	FGA=$(printf "%s\n" "$color7")
	SH1=$(printf "%s\n" "$color1")
	SH2=$(printf "%s\n" "$color2")
	SH3=$(printf "%s\n" "$color1")
	SH4=$(printf "%s\n" "$color2")
	SH5=$(printf "%s\n" "$color1")
	SH6=$(printf "%s\n" "$color2")
	SH7=$(printf "%s\n" "$color1")
	SH8=$(printf "%s\n" "$color2")
}

change_firefox() {
	if pywalfox update >/dev/null; then
		echof info "firefox colorscheme updated"
	else
		echof error "Firefox stayed the same"
	fi
}

change_rofi() {
	cat >"$ROFI_COLORS" <<-EOF
		/* colors */
		* {
		al: #00000000;
		bg: ${BG}FF;
		ac: ${SH8}FF;
		fg: ${FG}FF;
		se: ${FGA}FF;
		}
	EOF
	echof info "Rofi color scheme changed"
}

change_lockscreen() {
	if betterlockscreen -u "$1" >/dev/null; then
		echof info "Lockscreen changed"
	else
		echof info "Lockscreen stayed the same"
	fi
}

change_kitty() {
	sed -i -e "s/inactive_tab_background #.*/inactive_tab_background $BG/g" "$KITTY_COLORS"
	sed -i -e "s/active_tab_background #.*/active_tab_background $BG/g" "$KITTY_COLORS"
	sed -i -e "s/^active_tab_foreground #.*/active_tab_foreground $SH8/g" "$KITTY_COLORS"
	echof info "Kitty tab colorscheme changed"
}

change_dunst() {
	killall dunst
	sed -i -e "s/background = \"#.*/background = \"$FGA\"/g" "$DUNST_COLORS"
	sed -i -e "s/frame_color = \"#.*/frame_color = \"$FG\"/g" "$DUNST_COLORS"
	dunst &
	disown
	echof info "Dunst colorscheme changed"
}

change_polybar() {
	sed -i -e "s/background = #.*/background = $BG/g" "$POLYBAR_COLORS"
	sed -i -e "s/foreground = #.*/foreground = $FG/g" "$POLYBAR_COLORS"
	sed -i -e "s/foreground-alt = #.*/foreground-alt = $FGA/g" "$POLYBAR_COLORS"
	sed -i -e "s/shade1 = #.*/shade1 = $SH1/g" "$POLYBAR_COLORS"
	sed -i -e "s/shade2 = #.*/shade2 = $SH2/g" "$POLYBAR_COLORS"
	sed -i -e "s/shade3 = #.*/shade3 = $SH3/g" "$POLYBAR_COLORS"
	sed -i -e "s/shade4 = #.*/shade4 = $SH4/g" "$POLYBAR_COLORS"
	sed -i -e "s/shade5 = #.*/shade5 = $SH5/g" "$POLYBAR_COLORS"
	sed -i -e "s/shade6 = #.*/shade6 = $SH6/g" "$POLYBAR_COLORS"
	sed -i -e "s/shade7 = #.*/shade7 = $SH7/g" "$POLYBAR_COLORS"
	sed -i -e "s/shade8 = #.*/shade8 = $SH8/g" "$POLYBAR_COLORS"

	if polybar-msg cmd restart >/dev/null; then
		echof info "Polybar colors changed and polybar was restarted"
	else
		echof error "Polybar didn't restart"
	fi
}

change_sddm() {
	if sudo cp "$1" "$SDDM_BACKGROUND"; then
		echof info "sddm color scheme changed"
	else
		echof error "sddm color scheme change failed"
	fi
}

change_zathura() {
	if bash "$ZATHURA_FOLDER/generate.sh" >"$ZATHURA_FOLDER/zathurarc"; then
		echof info "zathura color scheme changed"
	else
		echof error "zathura color scheme change failed"
	fi
}

change_theme() {
	echof header "Changing wallpaper to $1"
	cp "$1" "$USER_HOME/.config/current_wallpaper"
	get_colors "$1"

	[[ $run_polybar ]] && change_polybar
	[[ $run_rofi ]] && change_rofi
	[[ $run_pywalfox ]] && change_firefox
	# [[ $run_kitty ]] && change_kitty
	[[ $run_zathura ]] && change_zathura
	[[ $run_dunst ]] && change_dunst
	[[ $run_betterlockscreen ]] && change_lockscreen "$1"
	[[ $run_sddm ]] && change_sddm "$1"
}

function interactive_mode() {
	echof header "Interactive mode activated"
	local selected=$(ls -t "$WALLPAPER_DIR" | sed -e 's/\..*$//' | $ROFI_COMMAND)
	[[ -z $selected ]] && echof error "No wallpaper selected" >&2 && exit 1
	echof info "Selected wallpaper: $selected"
	change_theme "$(find "$WALLPAPER_DIR" -name "$selected*")"
}

set_home_dir
init_config
check_features

if [[ -f "$1" ]]; then
	change_theme "$1"
else
	interactive_mode
fi
