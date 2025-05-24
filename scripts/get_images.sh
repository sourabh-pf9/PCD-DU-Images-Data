#!/bin/bash

NAMESPACE="sourabh-du-region-two"
OUTPUT_FILE="all-deployment-images_3.txt"

echo "Listing all images in deployments from namespace: $NAMESPACE" > $OUTPUT_FILE
echo "------------------------------------------------------------" >> $OUTPUT_FILE

deployments=$(kubectl get deployments -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}')

for deploy in $deployments; do
  echo "Deployment: $deploy" >> $OUTPUT_FILE
  
  containers=$(kubectl get deployment $deploy -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[*].name}')
  images=$(kubectl get deployment $deploy -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[*].image}')
  
  container_array=($containers)
  image_array=($images)

  for i in "${!container_array[@]}"; do
    echo "  Container: ${container_array[$i]}" >> $OUTPUT_FILE
    echo "  Image:     ${image_array[$i]}" >> $OUTPUT_FILE
  done

  echo "" >> $OUTPUT_FILE
done

echo "✅ Done. Output saved to $OUTPUT_FILE"

