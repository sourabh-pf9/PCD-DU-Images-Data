#!/usr/bin/env bash


NAMESPACE="sourabh-du"
echo "Shell: $BASH_VERSION"
# Define the image mapping (old → new)
declare -A IMAGE_MAP=(
  ["quay.io/platform9/alertmanager:0.26.0-pf9-865"]="quay.io/platform9/alertmanager:0.26.0-pf9-868"
  ["quay.io/platform9/blackbox-exporter:v0.23.0-pf9-392"]="quay.io/platform9/blackbox-exporter:v0.23.0-pf9-398"
  ["alpine/socat:1.7.4.4"]="alpine/socat:1.7.4.4"
  ["quay.io/platform9/pf9-clarity:2025.4.1-809"]="quay.io/platform9/pf9-clarity:1.0.0-804"
  ["docker.io/platform9/dex:0.0.0-112"]="docker.io/platform9/dex:0.0.0-119"
  ["quay.io/platform9/pf9-forwarder:2025.4.1-785"]="quay.io/platform9/pf9-forwarder:5.13.0-782"
  ["quay.io/platform9/hagrid:1.0.0-678"]="quay.io/platform9/hagrid:1.0.0-678"
  ["alpine/socat"]="alpine/socat"
  ["registry.k8s.io/ingress-nginx/controller:v1.12.1"]="registry.k8s.io/ingress-nginx/controller:v1.12.1"
  ["quay.io/platform9/pf9-keystone:2025.4.1-667"]="quay.io/platform9/pf9-keystone:2025.4.1-667"
  ["docker.io/library/memcached:1.5.5"]="docker.io/library/memcached:1.5.5"
  ["amazon/aws-cli"]="amazon/aws-cli"
  ["mysql:8.0.39"]="mysql:8.0.39"
  ["quay.io/platform9/mysqld-exporter:v0.12.1-pf9-422"]="quay.io/platform9/mysqld-exporterv0.13.0-pf9-436"
  ["quay.io/platform9/pf9-oidc-proxy:0.0.1"]="quay.io/platform9/pf9-oidc-proxy:0.0.1"
  ["quay.io/platform9/pf9-nginx:2025.4.1-1077-opencloud"]="quay.io/platform9/pf9-nginx1.0.0-838-opencloud"
  ["quay.io/platform9/pf9-notifications:2025.4.1-569"]="quay.io/platform9/pf9-notifications:5.13.0-566"
  ["quay.io/platform9/pf9-vault:2025.4.1-822"]="quay.io/platform9/pf9-vault:5.13.0-821"
  ["quay.io/platform9/preference-store:2025.4.1-516"]="quay.io/platform9/preference-store:5.12.1-513" 
  ["quay.io/platform9/prometheus:2.47.2-pf9-865"]="quay.io/platform9/prometheus:2.47.2-pf9-869"
  ["quay.io/platform9/pf9-rabbitmq:2025.4.1-583"]="quay.io/platform9/pf9-rabbitmq:2025.4.1-583"
  ["quay.io/platform9/pf9-remote-write-proxy:2025.4.1-269"]="quay.io/platform9/pf9-remote-write-proxy:5.13.0-267"
  ["quay.io/platform9/pf9-resmgr:2025.4.1-1233-opencloud"]="quay.io/platform9/pf9-resmgr:1.0.0-994-opencloud"
  ["quay.io/platform9/sentinel:2025.4.1-552"]="quay.io/platform9/sentinel:1.0.0-550"
  ["quay.io/platform9/pf9-pcd-ui:2025.4.1-333"]="quay.io/platform9/pf9-pcd-ui:1.0.0-266"
  ["quay.io/platform9/pf9-sidekickserver:2025.4.1-461"]="quay.io/platform9/pf9-sidekickserver:1.0.0-457"
  ["quay.io/platform9/vouch:2025.4.1-573"]="quay.io/platform9/vouch:1.0.0-570"
)

deployments=$(kubectl get deployments -n $NAMESPACE -o jsonpath='{.items[*].metadata.name}')

for deploy in $deployments; do
  echo "Processing deployment: $deploy"
  
  containers=$(kubectl get deployment $deploy -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[*].name}')
  images=$(kubectl get deployment $deploy -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[*].image}')
  
  container_array=($containers)
  image_array=($images)
  
  for i in "${!container_array[@]}"; do
    container="${container_array[$i]}"
    old_image="${image_array[$i]}"

    echo " - Checking $container in $old_image"
    echo "DEBUG: Looking up IMAGE_MAP for key: '$old_image'"

    # Proper lookup with full quoting
    new_image="${IMAGE_MAP["$old_image"]}"


    if [ -n "$new_image" ]; then
      echo " - Updating $container in $deploy: $old_image → $new_image"
      kubectl set image deployment/"$deploy" "$container=$new_image" -n "$NAMESPACE"
    else
      echo " - Skipping $container in $deploy: No mapping for $old_image"
    fi
  done
done

