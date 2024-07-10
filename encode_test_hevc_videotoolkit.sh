#!/bin/bash

# Check for input arguments
if [ $# -ne 1 ]; then
    echo "Usage: encode_test_hevc_videotoolbox.sh <input_file>"
    exit 1
fi

input="$1"
output_dir="encode_test"
output_file="$output_dir/results.csv"

mkdir -p "$output_dir"
touch "$output_file"

# Get video duration
duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input")
start_time=$(echo "($duration / 2) - 150" | bc)

# HEVC Videotoolbox Encoding options to test
bitrates=(500k 1M 2M 3M 4M 5M)  # Sample bitrates to test (adjust as needed)

echo "encoder,bitrate,file_size,video_bitrate" >> $output_file
for bitrate in "${bitrates[@]}"; do
    # Construct output filename with relevant info
    output="$output_dir/${bitrate}.mp4"

    echo "Encoding $input to $output..."

    start_time_sec=$(date +%s)

    ffmpeg -y -ss "$start_time" -t 60 -i "$input" \
        -loglevel error -stats \
        -c:v hevc_videotoolbox -b:v "$bitrate" -profile:v main -allow_sw 1 \
        -pix_fmt yuv420p -movflags +faststart \
        -c:a aac -b:a 128k -ac 2 \
        "$output" 

    end_time_sec=$(date +%s)
    elapsed_time=$((end_time_sec - start_time_sec))

    # Get file size and video bitrate
    file_size=$(wc -c < "$output")
    video_bitrate=$(mediainfo --Inform="Video;%BitRate%" "$output")

    echo "Encoding complete! Elapsed time: $elapsed_time seconds"
    echo "Output file: $output"
    echo "File size: $file_size bytes"
    echo "Video bitrate: $video_bitrate bps"
    echo "--------------------" 

    echo "hevc_videotoolbox,$bitrate,$file_size,$video_bitrate" >> $output_file
done