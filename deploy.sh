#!/bin/bash

# Add Helm repositories for Prometheus and Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

# Update Helm repositories
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/prometheus

# Install Grafana
helm install grafana grafana/grafana


# Expose Prometheus and Grafana services (if needed)
# kubectl expose service prometheus-server --type=LoadBalancer --name=prometheus-server-ext
# kubectl expose service grafana --type=LoadBalancer --name=grafana-ext


# Install Kafka-exporter
helm install kafka prometheus-community/prometheus-kafka-exporter

# Deploy DCGM exporter file
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: dcgm-exporter
  namespace: monitor-prom
spec:
  selector:
    matchLabels:
      app: dcgm-exporter
  template:
    metadata:
      labels:
        app: dcgm-exporter
    spec:
      nodeSelector:
        eks.amazonaws.com/nodegroup: gpu-thai
      containers:
      - name: dcgm-exporter
        image: nvcr.io/nvidia/k8s/dcgm-exporter:2.0.13-2.1.2-ubuntu18.04
        ports:
        - containerPort: 9400

# Deploy DCGM exporter service
---
apiVersion: v1
kind: Service
metadata:
  name: dcgm-exporter-service
  namespace: monitor-prom
spec:
  selector:
    app: dcgm-exporter
  ports:
    - protocol: TCP
      port: 9400
      targetPort: 9400
  type: ClusterIP
EOF



