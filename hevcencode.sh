#!/bin/sh
# A simple script to re-encode a video file in an HEVC mp4
# The goal is to achieve wide compatibility for use in slide decks and similar
# TODO: re-encode audio as well and make quality parameter a option for the script

# Sanity checks
if ! [ -x "$(command -v ffmpeg)" ]; then
    echo "ffmpeg is not installed -> exit"
    exit 1
fi
if [ "$#" -ne 1 ] || ! [ -f "$1" ]; then
    echo "Usage: $0 FILE"
    exit 1
fi

# Get the initial file size
init_size=$(du -h "$1" | cut -f1)

# Get the file path without the file extension
F=$1
F=${F%.*}

# Output file name
Fout="$F-hevc.mp4"

# crf can be tuned for better quality / smaller file size
# The range of the CRF scale is 0–51, where 0 is lossless,
# 23 is the default, and 51 is worst quality possible.
ffmpeg -v quiet -stats -i "$1" -pix_fmt yuv420p -c:v libx265 -crf 22 -tag:v hvc1 -movflags frag_keyframe+empty_moov+use_metadata_tags -map_metadata 0 -codec:a copy "$Fout"

# Get the new file size
new_size=$(du -h "$F-hevc.mp4" | cut -f1)

echo "\nCompressed from $init_size to $new_size"
