#!/bin/bash

# Author : Copyright (c) 2022 Adam Piaseczny
# Github Profile : https://github.com/TypicalAM

# A script to download youtube videos to a remote server and check their status
# it also support synchronizing with the remote server using rsync

TEMP_DIR="$HOME/temp"
TARGET_DIR="/home/adam/videos/youtube"
ICON="/usr/share/icons/McMojave-circle-purple/apps/scalable/appimagekit-youtube-dl-gui.svg"
ROFI_COMMAND='rofi -dmenu -i -p Queue -theme ~/.config/rofi/default_no_icons.rasi'
DEFAULT_CHOICE="poznan"

echof() {
				local colorReset="\033[0m"
				local prefix="$1"
				local message="$2"

				case "$prefix" in
								header) msgpfx="[\e[1;95mW\e[m]" color="";;
								act) msgpfx="[\e[1;97m=\e[m]" color="\033[0;34m";;
								info) msgpfx="[\e[1;92m*\e[m]" color="";;
								ok) msgpfx="[\e[1;93m+\e[m]" color="\033[0;32m";;
								error) msgpfx="[\e[1;91m!\e[m]" color="\033[0;31m";;
								*) msgpfx="" color="";;
				esac
				echo -e "$msgpfx$color $message $colorReset"
}

[ ! -f "/usr/bin/xclip" ] && echof error "no xclip" && exit 1
[ ! -f "/usr/bin/notify-send" ] && echof error "no notify-send" && exit 1
[ ! -f "/usr/bin/rofi" ] && echof error "no rofi" && exit 1
[ ! -d "$TEMP_DIR" ] || [ ! -w "$TEMP_DIR" ] && echo error "Temp dir not available" && exit 1


show_queue() {
	local option_1="View the video queue"
	local option_2="Download videos to local storage"
	local option_3="Change the server to $server_choice"
	local initial_choice=$(echo -e "$option_1\n$option_2\n$option_3"|$ROFI_COMMAND)
	case $initial_choice in
		$option_1)
			;;

		$option_2)
			download_to_local
			return
			;;

		$option_3)
			echo $server_choice > $TEMP_DIR/youtube_down_default
			notify-send -i $ICON "Changed the server!" "The download server has been changed to $server_choice"
			return
			;;

		*)
			return
			;;
	esac
	local new_videos_num="$(comm -23 <(ssh -p $port adam@$server /usr/bin/ls -I '\*.part' /opt/filmy/youtube |sort) <(/usr/bin/ls $TARGET_DIR |sort)|wc -l)"
	local out="$(ssh adam@$server -p $port bash /opt/filmy/show_queue.sh)"
	local choice=$(echo -e "$out\n[Action] Download to local ($new_videos_num new)" | $ROFI_COMMAND)
	[[ $choice == "[Action]"* ]] && download_to_local
}

download_to_local() {
	notify-send -i $ICON "Transfering files" "Trying to transfer files via rsync..."
	local first="$(ls $TARGET_DIR)"
	rsync -avzh -e "ssh -p $port" --exclude '*.part' adam@$server:/opt/filmy/youtube/ $TARGET_DIR
	local second="$(ls $TARGET_DIR)"
	[ ! "$first" == "$second" ] && notify-send -i $ICON "Files downloaded" "They are available in the Youtube directory"
	[ "$first" == "$second" ] && notify-send -i $ICON "Nothing has been copied"
}

add_to_queue() {
	local video_link="$(xclip -selection clipboard -o)"
	local out=$(ssh adam@$server -p $port bash /opt/filmy/add_to_queue.sh \'$video_link\')
	echo $out
	[ "$out" == "Video added for download" ] && notify-send -i $ICON "Video queued" "$video_link has been queued remotely" && exit
	notify-send -i $ICON "Video not added" "The link seems to be invalid" && exit
}

check_server() {
	local filename="$TEMP_DIR/youtube_down_default"
  [ ! -f $filename ] && echo $DEFAULT_CHOICE > $filename
	local chosen_server=$(cat $filename)
	if [ "$chosen_server" == "swino" ] ; then
		server='192.168.1.240'
		port='22'
		server_choice=poznan
	else
		server='cloud.bazela.com.pl'
		port='2002'
		server_choice=swino
	fi
}

check_server
[ "$1" == "--add" ] && add_to_queue && exit
[ "$1" == "--queue" ] && show_queue && exit
