#!/bin/bash

# Check for input arguments
if [ $# -ne 1 ]; then
    echo "Usage: encode_test.sh <input_file>"
    exit 1
fi

input="$1"
output_dir="encode_test"
output_file="$output_dir/results.csv"

mkdir -p "$output_dir"
touch $output_file

# Get video duration
duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input")
start_time=$(echo "($duration / 2) - 150" | bc)

# x265 Encoding options to test
crf_values=(18 20 23 25 28 32 35)
presets=("veryslow" "slower" "slow" "medium" "fast" "faster" "veryfast" "superfast" "ultrafast")
profiles=("main" "main10")
levels=(3.1 4.0 5.0)  # Adjust levels to test based on target devices

options=()

for crf in "${crf_values[@]}"; do
  for preset in "${presets[@]}"; do
    for profile in "${profiles[@]}"; do
      for level in "${levels[@]}"; do
        options+=("-c:v libx265 -crf $crf -preset $preset -profile:v $profile -level $level")
      done
    done
  done
done

echo "elapsed_time,file_size,video_bitrate,encoder,crf,preset,profile,level" >> "$output_file"

for opt in "${options[@]}"; do
    encoder=$(echo "$opt" | awk '{print $2}')
    crf=$(echo "$opt" | awk '{print $4}')
    preset=$(echo "$opt" | awk '{print $6}')
    profile=$(echo "$opt" | awk '{print $8}')
    level=$(echo "$opt" | awk '{print $10}')

    output="$output_dir/${encoder}_${preset}_$_crf${crf}_${profile}_${level}.mp4"

    echo "Encoding $input to $output..."

    start_time_sec=$(date +%s)

    ffmpeg -y -ss $start_time -t 60 -i "$input" \
            -loglevel error -stats \
            -x265-params log-level=error \
            $opt \
            -pix_fmt yuv420p -movflags +faststart \
            -c:a aac -b:a 128k -ac 2 \
            "$output"

    end_time_sec=$(date +%s)
    elapsed_time=$((end_time_sec - start_time_sec))

    file_size=$(wc -c < "$output")
    video_bitrate=$(mediainfo --Inform="Video;%BitRate%" "$output")

    echo "Encoding complete! Elapsed time: $elapsed_time seconds"
    echo "Output file: $output" 
    echo "File size: $file_size bytes" 
    echo "Video bitrate: $video_bitrate bps"
    echo "--------------------"

    echo "$elapsed_time,$file_size,$video_bitrate,$encoder,$crf,$preset,$profile,$level" >> "$output_file" 
done