#!/bin/bash

OUTPUT_FILE="non_multiplatform_images.txt"
INPUT_FILE="architecture_support.txt"

echo "Images that don't support multiplatform:" > "$OUTPUT_FILE"
echo "=======================================" >> "$OUTPUT_FILE"

# Filter images that don't have multiplatform support
grep -v "Supports both AMD64 and ARM64" "$INPUT_FILE" | grep -v "^$" >> "$OUTPUT_FILE"

echo "✅ Non-multiplatform images have been saved to $OUTPUT_FILE"