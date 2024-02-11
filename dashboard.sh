#!/bin/bash

GRAFANA_URL="http://a34b78cb3f16341ce9aad5788674227a-1606254003.us-east-1.elb.amazonaws.com/api/dashboards/db"
SERVICE_ACCOUNT_TOKEN="glsa_NtgwDPMuj4cIkDma6hGQDNpZVT5RnJtT_fa7b950d"
PROMETHEUS_UID="aa754dbe1cff84abab3e2554677de347-1836917625.us-east-1.elb.amazonaws.com"  # Replace with your Prometheus datasource UID

# JSON data for your dashboard configuration
DASHBOARD_DATA=$(cat <<EOF
{
  "__inputs": [
    {
      "name": "DS_PROMETHEUS",
      "label": "prometheus",
      "description": "",
      "type": "datasource",
      "pluginId": "prometheus",
      "pluginName": "Prometheus"
    }
  ],
  "__elements": {},
  "__requires": [
    {
      "type": "grafana",
      "id": "grafana",
      "name": "Grafana",
      "version": "10.2.3"
    },
    {
      "type": "datasource",
      "id": "prometheus",
      "name": "Prometheus",
      "version": "1.0.0"
    },
    {
      "type": "panel",
      "id": "timeseries",
      "name": "Time series",
      "version": ""
    }
  ],
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": {
          "type": "grafana",
          "uid": "-- Grafana --"
        },
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "id": null,
  "links": [],
  "liveNow": false,
  "panels": [
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${PROMETHEUS_UID}"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisBorderShow": false,
            "axisCenteredZero": false,
            "axisColorMode": "text",
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 0,
            "gradientMode": "none",
            "hideFrom": {
              "legend": false,
              "tooltip": false,
              "viz": false
            },
            "insertNulls": false,
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "auto",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          }
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "id": 1,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "${PROMETHEUS_UID}"
          },
          "disableTextWrap": false,
          "editorMode": "builder",
          "expr": "DCGM_FI_DEV_GPU_UTIL{job=\"dcgm-exporter\"}",
          "fullMetaSearch": false,
          "includeNullMetadata": true,
          "instant": true,
          "legendFormat": "__auto",
          "range": true,
          "refId": "A",
          "useBackend": false
        }
      ],
      "title": "Kubernetes GPU Utilization(in %) - ",
      "transformations": [],
      "type": "timeseries"
    }
  ],
  "refresh": "",
  "schemaVersion": 39,
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "Kubernetes GPU Nodes",
  "uid": "e61671ae-4eaf-4255-a17f-119f2140bd21",
  "version": 2,
  "weekStart": ""
}
EOF
)

# Create the dashboard using the Grafana API
curl -v -H "Authorization: Bearer $SERVICE_ACCOUNT_TOKEN" -H "Content-Type: application/json" -d "$DASHBOARD_DATA" "$GRAFANA_URL"
