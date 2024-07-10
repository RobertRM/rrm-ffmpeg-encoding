#!/bin/bash

input_file="$1"

# Check if input file exists and is not already an MKV file
if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file '$input_file' does not exist."
    exit 1
elif [[ "${input_file##*.}" == "mkv" ]]; then  # Check file extension
    echo "Skipping '$input_file': Already in MKV format."
    exit 0 
fi

filename=$(basename "$input_file" | sed 's/\.[^.]*$//')

ffmpeg -y -i "$input_file" -c copy "$filename.mkv" --loglevel error -stats

# Error handling
if [[ $? -ne 0 ]]; then
    echo "Error: Encoding failed. See ffmpeg_log.txt for details."
    exit 1
fi

echo "Encoding complete: $filename.mkv"