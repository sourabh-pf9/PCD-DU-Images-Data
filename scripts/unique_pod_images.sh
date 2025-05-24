#!/bin/bash

# ======== STEP 0: SET NAMESPACES =========
# Replace these with your desired namespaces
NAMESPACES=("sourabh-du-region-two")

# ======== STEP 1: COLLECT ALL IMAGES FROM PODS =========
echo "🔍 Collecting images from namespaces: ${NAMESPACES[*]}"
all_images=()

for ns in "${NAMESPACES[@]}"; do
  echo "📦 Namespace: $ns"

  pods=$(kubectl get pods -n "$ns" -o jsonpath='{.items[*].metadata.name}')

  for pod in $pods; do
    echo "  → Pod: $pod"

    # Get container and initContainer images
    images=$(kubectl get pod "$pod" -n "$ns" -o jsonpath='{range .spec.initContainers[*]}{.image}{"\n"}{end}{range .spec.containers[*]}{.image}{"\n"}{end}')
    
    while IFS= read -r img; do
      [[ -n "$img" ]] && all_images+=("$img")
    done <<< "$images"
  done
done

# ======== STEP 2: DEDUPLICATE IMAGES =========
unique_images=($(printf "%s\n" "${all_images[@]}" | sort -u))

echo -e "\n✅ Found ${#unique_images[@]} unique images."
printf "%s\n" "${unique_images[@]}"