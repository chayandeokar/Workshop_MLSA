#!/bin/bash

GRAFANA_URL="http://a34b78cb3f16341ce9aad5788674227a-1606254003.us-east-1.elb.amazonaws.com"  # Replace with your Grafana URL
GRAFANA_SERVICE_ACCOUNT="glsa_rtAVBWw790BSaGkgOGclynqXWUlGuLAu_afd0b2b6"  # Replace with your Grafana service account
PROMETHEUS_NAME="Prometheus"
PROMETHEUS_URL="http://aa754dbe1cff84abab3e2554677de347-1836917625.us-east-1.elb.amazonaws.com:80"  # Replace with your Prometheus URL

# Create Prometheus data source payload
PAYLOAD=$(cat <<EOF
{
  "name": "${PROMETHEUS_NAME}",
  "type": "prometheus",
  "url": "${PROMETHEUS_URL}",
  "access": "proxy",
  "basicAuth": false,
  "isDefault": true
}
EOF
)

# Add Prometheus data source using Grafana API with service account token
response=$(curl -s -k -X POST "${GRAFANA_URL}/api/datasources" \
    -H "Authorization: Bearer $(cat E:/kubectl/token.txt)" \
    -H "Content-Type: application/json" \
    -d "${PAYLOAD}"
)

# Check if the data source was added successfully
if [ "$(echo "${response}" | jq -r '.id')" != "null" ]; then
    echo "Prometheus data source added successfully with ID: $(echo "${response}" | jq -r '.id')"
else
    echo "Failed to add Prometheus data source. Error: $(echo "${response}" | jq -r '.message')"
fi
