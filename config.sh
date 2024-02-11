#!/bin/bash

# Define Prometheus deployment and namespace
PROMETHEUS_DEPLOYMENT="prometheus-server"

# Prometheus configuration file
CONFIG_FILE="prometheus-server.yaml"

# Prometheus job configuration
JOB_CONFIG=$(cat <<EOF
  - job_name: 'dcgm-exporter'
    static_configs:
      - targets: ['your-target-service:your-port']
EOF
)

# Create temporary job configuration file
JOB_CONFIG_FILE=$(mktemp)
echo "$JOB_CONFIG" > "$JOB_CONFIG_FILE"

# Patch Prometheus deployment with job configuration
kubectl patch deployment "$PROMETHEUS_DEPLOYMENT" \
  --patch "$(cat <<EOF
spec:
  template:
    spec:
      containers:
      - name: prometheus
        volumeMounts:
        - name: prometheus-config-volume
          mountPath: /etc/prometheus
          readOnly: true
      volumes:
      - name: prometheus-config-volume
        configMap:
          name: prometheus-config
          items:
          - key: prometheus.yml
            path: prometheus.yml
          - key: job-config.yml
            path: job-config.yml
EOF
)" --type='json'

# Add job configuration to Prometheus configuration file ConfigMap
kubectl create configmap prometheus-server --from-file=prometheus.yml="$CONFIG_FILE" --from-file=job-config.yml="$JOB_CONFIG_FILE" -o yaml --dry-run=client | kubectl apply -f -

# Clean up temporary job configuration file
rm "$JOB_CONFIG_FILE"
