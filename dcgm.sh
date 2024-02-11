#!/bin/bash

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
EOF

# Deploy DCGM exporter service
kubectl apply -f dcgm-exporter-service.yaml