# Files Explained

- `.github/workflows/pipeline.yml`: 5-stage CI pipeline for compose validation, config linting, stack boot, smoke checks, and alert rule verification.
- `CHEATSHEET.md`: quick commands for local monitoring tasks and troubleshooting.
- `FILES_EXPLAINED.md`: short purpose statement for every tracked file.
- `README.md`: main lab guide, dashboard details, and CI overview.
- `docker-compose.yml`: Compose stack for Prometheus, Node Exporter, and Grafana.
- `grafana/dashboards/infrastructure-health.json`: provisioned dashboard JSON.
- `grafana/provisioning/dashboards/dashboard.yml`: Grafana dashboard provisioning config.
- `grafana/provisioning/datasources/datasource.yml`: Grafana datasource provisioning config.
- `prometheus/prometheus.yml`: scrape and rule configuration for Prometheus.
- `prometheus/alerts.yml`: basic alert rules for the lab.
- `scripts/smoke.sh`: endpoint smoke checks for Prometheus, Node Exporter, and Grafana.
