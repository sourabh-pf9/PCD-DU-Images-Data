#!/bin/bash

# Output file for cleaned image names
OUTPUT_FILE="cleaned_images.txt"

# ======== STEP 0: SET NAMESPACES =========
NAMESPACES=("sourabh-du-region-two")

# ======== STEP 1: COLLECT ALL IMAGES FROM ALL RESOURCES =========
echo "🔍 Collecting images from namespaces: ${NAMESPACES[*]}"
all_images=()

for ns in "${NAMESPACES[@]}"; do
    echo "📦 Scanning namespace: $ns"
    
    # Get images from various resource types
    resources=(
        "deployments"
        "statefulsets"
        "daemonsets"
        "cronjobs"
        "jobs"
        "pods"
    )

    for resource in "${resources[@]}"; do
        echo "  → Scanning $resource"
        
        # Get all container images including init containers
        images=$(kubectl get $resource -n "$ns" -o jsonpath='{range .items[*]}{range .spec.template.spec.initContainers[*]}{.image}{"\n"}{end}{range .spec.template.spec.containers[*]}{.image}{"\n"}{end}' 2>/dev/null)
        
        # For pods (they have a different path)
        if [ "$resource" == "pods" ]; then
            images=$(kubectl get pods -n "$ns" -o jsonpath='{range .items[*]}{range .spec.initContainers[*]}{.image}{"\n"}{end}{range .spec.containers[*]}{.image}{"\n"}{end}' 2>/dev/null)
        fi
        
        while IFS= read -r img; do
            [[ -n "$img" ]] && all_images+=("$img")
        done <<< "$images"
    done
done

# ======== STEP 2: CLEAN AND DEDUPLICATE IMAGES =========
# Remove ECR prefix and get unique images
cleaned_images=($(printf "%s\n" "${all_images[@]}" | sed 's|.*amazonaws\.com/||' | sort -u))

echo -e "\n✅ Found ${#cleaned_images[@]} unique images."

# Write cleaned images to file
printf "%s\n" "${cleaned_images[@]}" > "$OUTPUT_FILE"

echo "✍️  Written cleaned image names to $OUTPUT_FILE"