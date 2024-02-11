#!/bin/bash

# Define the new alerting rules
NEW_ALERTING_RULES=$(cat <<EOF
  groups:
  - name: kafka_consumer_lag_alerts
    rules:
    - alert: KafkaConsumerGroupLagTooHigh
      expr: kafka_consumergroup_lag_sum > -1
      for: 0m
      annotations:
        summary: "Kafka Consumer Group Lag Too High"
        description: "The Kafka consumer group lag for group 'ai_pred' is too high."
EOF
)

# Retrieve the current Prometheus configuration data
CURRENT_PROM_CONFIG=$(kubectl get configmap prometheus-server -o=jsonpath='{.data.prometheus\.yml}')

# Define the pattern to search for where to insert the new alerting rules
PATTERN="^  alerts: \|"

# Insert the new alerting rules into the Prometheus configuration data
UPDATED_PROM_CONFIG=$(echo "$CURRENT_PROM_CONFIG" | sed "/$PATTERN/a\ $NEW_ALERTING_RULES")

# Update the ConfigMap with the modified Prometheus configuration data
kubectl create configmap prometheus-server --from-literal=prometheus.yml="$UPDATED_PROM_CONFIG" --dry-run=client -o yaml | kubectl apply -f -
