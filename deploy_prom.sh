#!/bin/bash


# Add Helm repositories for Prometheus and Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

# Update Helm repositories
helm repo update

# Install Prometheus using the specified values file
helm install prometheus prometheus-community/prometheus 

