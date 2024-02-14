#!/bin/bash

# How to write Shell Script
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
  # Append the new scrape configuration after the existing one

  UPDATED_CM_DATA=$(echo -e "$CURRENT_CM_DATA\n$NEW_SCRAPE_CONFIG")

  # Create a temporary file with the updated ConfigMap data
  TMP_FILE=$(mktemp)
  echo "prometheus.yml: |-" > "$TMP_FILE"
  echo "$UPDATED_CM_DATA" >> "$TMP_FILE"

  # Apply the updated ConfigMap data
  kubectl apply -f "$TMP_FILE"

  # Patch the annotation to avoid the warning
  kubectl patch configmap prometheus-server -p '{"metadata":{"annotations":{"kubectl.kubernetes.io/last-applied-configuration":"'"$(kubectl get configmap prometheus-server -o=jsonpath='{.metadata.annotations.kubectl\.kubernetes\.io/last-applied-configuration}')"'"}}}'
  
  # Remove the temporary file
  rm "$TMP_FILE"
fi
