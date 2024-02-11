#!/bin/bash

# Add Helm repositories for Prometheus and Grafana
helm repo add grafana https://grafana.github.io/helm-charts

# Update Helm repositories
helm repo update


# Install Grafana
helm install grafana grafana/grafana


kubectl expose service grafana --type=LoadBalancer 
