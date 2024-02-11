#!/bin/bash

# Define the new scrape configuration
NEW_SCRAPE_CONFIG=$(cat <<EOF
  - job_name: 'dcgm-exporter'
    static_configs:
      - targets: ['dcgm-exporter-service:9400']
  - job_name: 'kafka-exporter'
    static_configs:
      - targets: ['kafka:9308']
EOF
)

# Retrieve the current ConfigMap data
CURRENT_CM_DATA=$(kubectl get configmap prometheus-server -o=jsonpath='{.data.prometheus\.yml}')

# If the ConfigMap doesn't exist yet, create it with the new scrape configuration
if [ -z "$CURRENT_CM_DATA" ]; then
  kubectl create configmap prometheus-server --from-literal=prometheus.yml="$NEW_SCRAPE_CONFIG"
else
  # Escape the new scrape configuration for use in awk
  ESCAPED_NEW_SCRAPE_CONFIG=$(echo "$NEW_SCRAPE_CONFIG" | awk '{ gsub(/"/, "\\\""); print }')

  # Merge the new scrape configuration with the existing ConfigMap data
  UPDATED_CM_DATA=$(echo -e "$CURRENT_CM_DATA" | awk '/rule_files:/ {print; print "'"$ESCAPED_NEW_SCRAPE_CONFIG"'"; next} 1')

  # Update the ConfigMap with the modified data
  kubectl create configmap prometheus-server --from-literal=prometheus.yml="$UPDATED_CM_DATA" --dry-run=client -o yaml | kubectl apply -f -
fi
