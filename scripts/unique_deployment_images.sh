#!/bin/bash

# ======== STEP 0: SET NAMESPACES =========
# Replace these with your desired namespaces
NAMESPACES=("sourabh-du-region-two")

# ======== STEP 1: COLLECT ALL IMAGES FROM DEPLOYMENTS =========
echo "🔍 Collecting images from namespaces: ${NAMESPACES[*]}"
all_images=()

for ns in "${NAMESPACES[@]}"; do
  echo "📦 Namespace: $ns"

  deployments=$(kubectl get deployments -n "$ns" -o jsonpath='{.items[*].metadata.name}')

  for deployment in $deployments; do
    echo "  → Deployment: $deployment"

    # Get container and initContainer images from deployment spec
    images=$(kubectl get deployment "$deployment" -n "$ns" -o jsonpath='{range .spec.template.spec.initContainers[*]}{.image}{"\n"}{end}{range .spec.template.spec.containers[*]}{.image}{"\n"}{end}')
    
    while IFS= read -r img; do
      [[ -n "$img" ]] && all_images+=("$img")
    done <<< "$images"
  done
done

# ======== STEP 2: DEDUPLICATE IMAGES =========
unique_images=($(printf "%s\n" "${all_images[@]}" | sort -u))

echo -e "\n✅ Found ${#unique_images[@]} unique images."
printf "%s\n" "${unique_images[@]}"