# Local Monitoring Lab Cheatsheet

This cheatsheet explains **what each piece is for**, common commands, and fast troubleshooting for the Prometheus + Node Exporter + Grafana lab.

## 1) What this lab gives you

- **Prometheus** collects and stores metrics.
- **Node Exporter** exposes host machine metrics (CPU, memory, disk, filesystem, etc.).
- **Grafana** visualizes those metrics with a ready dashboard.

## 2) Core commands (day-1 workflow)

```bash
# Start stack in background
docker compose up -d

# Check if containers are running
docker compose ps

# Follow logs (all services)
docker compose logs -f

# Run smoke checks against endpoints
./scripts/smoke.sh

# Stop everything
docker compose down
```

## 3) URLs and credentials

- Prometheus UI: http://localhost:9090
- Node Exporter metrics: http://localhost:9100/metrics
- Grafana UI: http://localhost:3000
  - username: `admin`
  - password: `admin`

## 4) What each directory/file is for

- `docker-compose.yml`
  - Defines the three containers, ports, and mounted config/provisioning paths.
- `prometheus/prometheus.yml`
  - Prometheus scrape config for itself and node-exporter.
- `grafana/provisioning/datasources/datasource.yml`
  - Auto-creates Prometheus datasource in Grafana.
- `grafana/provisioning/dashboards/dashboard.yml`
  - Tells Grafana where to load dashboard JSON files from.
- `grafana/dashboards/infrastructure-health.json`
  - Dashboard JSON with infrastructure health panels.
- `scripts/smoke.sh`
  - Curl-based endpoint checks for Prometheus, Node Exporter, and Grafana.
- `.github/workflows/pipeline.yml`
  - CI pipeline with 4 stages/jobs (compose validation, boot, health checks, lint).

## 5) Useful Prometheus queries

```promql
# Is node exporter up?
up{job="node_exporter"}

# CPU usage percentage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Available memory bytes
node_memory_MemAvailable_bytes

# Disk free bytes per filesystem
node_filesystem_free_bytes{fstype!="tmpfs"}
```

## 6) Troubleshooting quick fixes

### Grafana starts but no dashboard appears
- Ensure provisioning files are mounted correctly.
- Check logs:
  ```bash
  docker compose logs grafana
  ```
- Verify JSON dashboard is valid:
  ```bash
  jq . grafana/dashboards/infrastructure-health.json >/dev/null
  ```

### Prometheus target is DOWN
- Open `http://localhost:9090/targets`.
- Confirm service name `node-exporter:9100` exists in `prometheus.yml`.
- Restart stack:
  ```bash
  docker compose down && docker compose up -d
  ```

### Smoke test fails on Grafana
- Grafana can take longer to become healthy than Prometheus.
- Retry after 10-20 seconds.
- If needed, test manually:
  ```bash
  curl -u admin:admin http://localhost:3000/api/health
  ```

## 7) Lint and validation commands

```bash
# Validate docker compose syntax
docker compose config >/dev/null

# Validate Prometheus config format inside official container
docker run --rm -v "$PWD/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro" \
  prom/prometheus:v2.54.1 promtool check config /etc/prometheus/prometheus.yml

# Validate dashboard JSON
jq . grafana/dashboards/infrastructure-health.json >/dev/null

# Validate smoke script syntax
bash -n scripts/smoke.sh
```
