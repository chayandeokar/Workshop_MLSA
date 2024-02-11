#!/bin/bash

# Update the 'prometheus.yml' within the ConfigMap
kubectl patch configmap prometheus-server -n default --type merge --patch "$(cat <<EOF
data:
  prometheus.yml: |
    scrape_configs:
      - job_name: 'dcgm'
        static_configs:
          - targets: ['dcgm-exporter:9091']
EOF
)"