#!/bin/bash

# Check for input arguments
if [ $# -ne 2 ]; then
  echo "Usage: encode.sh <input_file> <output_file>"
  exit 1
fi

input="$1"
output="$2"

echo "Encoding $input to $output..."

# Start the timer
start_time=$(date +%s)

ffmpeg -y -i "$input" \
    -loglevel error -stats  \
    -c:v libx264 -crf 23 -preset medium -profile:v main -level 3.1 \
    -pix_fmt yuv420p -movflags +faststart \
    -c:a aac -b:a 128k -ac 2 \
    "$output"

# Stop the timer
end_time=$(date +%s)

# Calculate and display the elapsed time
elapsed_time=$((end_time - start_time))
echo "Encoding complete! Elapsed time: $elapsed_time seconds"