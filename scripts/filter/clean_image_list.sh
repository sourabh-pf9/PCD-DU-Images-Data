#!/bin/bash

INPUT_FILE="non_multiplatform_images.txt"
OUTPUT_FILE="clean_images.txt"

# Keep the header
head -n 2 "$INPUT_FILE" > "$OUTPUT_FILE"

# Remove the ": No architecture information found ❌" from the rest of the file
sed -n '3,$p' "$INPUT_FILE" | sed 's/: No architecture information found ❌//' | \
sed 's/: Error fetching manifest//' >> "$OUTPUT_FILE"

# Replace the original file with the cleaned version
mv "$OUTPUT_FILE" "$INPUT_FILE"

echo "✅ Successfully cleaned the image list"