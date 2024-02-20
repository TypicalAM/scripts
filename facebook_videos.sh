#!/usr/bin/env bash
#
# Converts videos from obs for sending them to facebook made because 
# of the buggy nature of sending mkv files and the 25 MB file limit

INPUT_DIR="$HOME/videos"
OUTPUT_DIR="$HOME/videos/converted"

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

ensure_available() {
	command -v "${1}" >/dev/null 2>&1 || {
		echof error "${1} isn't available!" >&2
		exit 1
	}
}

check_files() {
	[[ ! -d "$INPUT_DIR" ]] || [[ ! -w "$INPUT_DIR" ]] && echof error "The input directory doesnt exist or you have no permisions"
	[[ ! -d "$OUTPUT_DIR" ]] || [[ ! -w "$OUTPUT_DIR" ]] && echof error "The output directory doesnt exist or you have no permisions"
}

main() {
	# Grab absolute path of the last video file from the input folder
	target_size="18"
	INPUT_FILENAME="$(ls -t1 $INPUT_DIR -p | grep -v / | head -n 1)"
	TARGET_FILE="${INPUT_FILENAME%.*}-minified.mp4"
	INPUT_FILE=$INPUT_DIR/$INPUT_FILENAME

	echof header "Converting a video to mp4 and decreasing its size"
	echof info "Input filename: $INPUT_FILE"
	echof info "Output filename: $TARGET_FILE"
}

initialize() {
	echof info "Setting the necessary variables"
	og_duration_seconds=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$INPUT_FILE")
	og_audio_rate=$(ffprobe -v error -select_streams a:0 -show_entries stream=bit_rate -of csv=p=0 "$INPUT_FILE")
	og_audio_rate=$(awk -v arate="$og_audio_rate" 'BEGIN { printf "%.0f", (arate / 1024) }')
	target_minsize=$(awk -v arate="$og_audio_rate" -v duration="$og_duration_seconds" 'BEGIN { printf "%.2f", ( (arate * duration) / 8192 ) }')
	target_size_ok=$(awk -v size="$target_size" -v minsize="$target_minsize" 'BEGIN { print (minsize < size) }')
	if [[ $target_size_ok -eq 0 ]]; then
		echof error "The target size ${target_size}MB is too small!"
		echof act "Try values larger than ${target_minsize}MB"
		exit 1
	fi
	target_audio_rate=$og_audio_rate
	target_video_rate=$(awk -v size="$target_size" -v duration="$og_duration_seconds" -v audio_rate="$og_audio_rate" 'BEGIN { print  ( ( size * 8192.0 ) / ( 1.048576 * duration ) - audio_rate) }')
}

convert() {
	echof info "Performing the conversion"
	ffmpeg -y -i "$INPUT_FILE" -c:v libx264 -b:v "$target_video_rate"k -pass 1 -v 8 -an -f mp4 /dev/null &&
		ffmpeg -i "$INPUT_FILE" -c:v libx264 -v 8 -b:v "$target_video_rate"k -pass 2 -c:a aac -b:a "$target_audio_rate"k "$OUTPUT_DIR/$TARGET_FILE"
	echof info "Removing the temporary files"
	rm ffmpeg2pass-0.log
	rm ffmpeg2pass-0.log.mbtree
	echof ok "Everything done!"
}

ensure_available "ffmpeg"

check_files
main
initialize
convert
