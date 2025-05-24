#!/bin/bash

OUTPUT_FILE="architecture_support.txt"
INPUT_FILE="cleaned_images.txt"

# Ensure docker is logged into required registries
echo "⚠️  Make sure you're logged into required registries (docker.io, quay.io, ghcr.io)"

# Function to check architecture support
check_arch_support() {
    local image="$1"
    echo "Checking: $image"
    
    # Get manifest information
    manifest_info=$(docker manifest inspect "$image" 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "$image: Error fetching manifest" >> "$OUTPUT_FILE"
        return
    fi    # Changed '}' to 'fi'
    
    # Check for supported architectures
    local supports_amd64=$(echo "$manifest_info" | grep -c "amd64")
    local supports_arm64=$(echo "$manifest_info" | grep -c "arm64")
    
    # Write results
    if [ $supports_amd64 -gt 0 ] && [ $supports_arm64 -gt 0 ]; then
        echo "$image: Supports both AMD64 and ARM64 ✅" >> "$OUTPUT_FILE"
    elif [ $supports_amd64 -gt 0 ]; then
        echo "$image: Supports only AMD64 ⚠️" >> "$OUTPUT_FILE"
    elif [ $supports_arm64 -gt 0 ]; then
        echo "$image: Supports only ARM64 ⚠️" >> "$OUTPUT_FILE"
    else
        echo "$image: No architecture information found ❌" >> "$OUTPUT_FILE"
    fi
}

# Clear previous results
> "$OUTPUT_FILE"

# Process each image
while IFS= read -r image; do
    # Skip empty lines
    [ -z "$image" ] && continue
    check_arch_support "$image"
done < "$INPUT_FILE"

echo "✅ Architecture support check complete. Results saved in $OUTPUT_FILE"