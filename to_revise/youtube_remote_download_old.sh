#!/bin/bash

[ ! -f "/usr/bin/xclip" ] && echof error "no xclip"
[ ! -f "/usr/bin/notify-send" ] && echof error "no notify-send"
[ ! -f "/usr/bin/rofi" ] && echof error "no rofi"

ICON=/usr/share/icons/McMojave-circle-purple/apps/scalable/appimagekit-youtube-dl-gui.svg

DEFAULT_SERVER=poznan

show_queue() {
				local new_videos_num="$(comm -23 <(ssh -p $port adam@$server /usr/bin/ls -I '\*.part' /opt/filmy/youtube |sort) <(/usr/bin/ls /home/adam/videos/youtube |sort)|wc -l)"
				local out="$(ssh adam@$server -p $port bash /opt/filmy/show_queue.sh)"
				local choice=$(echo -e "$out\n[Action] Download to local ($new_videos_num new)" | rofi -dmenu -i -p "Queue" -theme /home/adam/.config/rofi/launchers/colorful/default_no_icons.rasi)
				[[ $choice == "[Action]"* ]] && download_to_local
}

display_undownloaded() {
				local new_videos_num="$(comm -23 <(ssh -p $port adam@$server /usr/bin/ls -I '\*.part' /opt/filmy/youtube |sort) <(/usr/bin/ls /home/adam/videos/youtube |sort)|wc -l)" >/dev/null
				echo " $new_videos_num"
				#
}

download_to_local() {
				notify-send -i $ICON "Transfering files" "Trying to transfer files via rsync..."
				local first="$(ls /home/adam/videos/youtube)"
				rsync -avzh -e "ssh -p $port" --exclude '*.part' adam@$server:/opt/filmy/youtube/ /home/adam/videos/youtube
				local second="$(ls /home/adam/videos/youtube)"
				[ ! "$first" == "$second" ] && notify-send -i $ICON "Files downloaded" "They are available in the Youtube directory"
				[ "$first" == "$second" ] && notify-send -i $ICON "Nothing has been copied"
}

add_to_queue() {
				local video_link="$(xclip -selection clipboard -o)"
				local out=$(ssh adam@$server -p $port bash /opt/filmy/add_to_queue.sh \"$video_link\")
				echo $out
				[ "$out" == "Video added for download" ] && notify-send -i $ICON "Video queued" "$video_link has been queued remotely" && exit
				notify-send -i $ICON "Video not added" "The link seems to be invalid" && exit
}

check_server() {
				if [ "$DEFAULT_SERVER" == "swino" ] ; then
								server='192.168.1.240'
								port='22'
				else
								server='cloud.bazela.com.pl'
								port='2002'
				fi
}

check_server
[ "$1" == "queue" ] && show_queue && exit
[ "$1" == "status" ] && display_undownloaded && exit
[ ! "$1" == "queue" ] && add_to_queue && exit
