# Prometheus + Node Exporter + Grafana (Local Monitoring Lab)

Intermediate monitoring lab to observe local infrastructure metrics quickly using Docker Compose.

## What you will run

- **Prometheus** for metrics collection and querying.
- **Node Exporter** for host-level metrics.
- **Grafana** for dashboard visualization (auto-provisioned).
- **Alert rules** for a basic target-down signal.

## Project tree (with short explanation)

```text
.
├── docker-compose.yml                             # Runs Prometheus, Node Exporter, Grafana (+ persistent volumes)
├── README.md                                      # Lab setup + usage guide
├── .env.example                                   # Optional env overrides for Grafana + smoke tuning
├── CHEATSHEET.md                                  # Fast commands + troubleshooting + query references
├── prometheus/
│   ├── alerts.yml                                 # Basic alert rules for the lab
│   └── prometheus.yml                             # Prometheus scrape and rule configuration
├── grafana/
│   ├── dashboards/
│   │   └── infrastructure-health.json             # Infrastructure Health dashboard JSON
│   └── provisioning/
│       ├── datasources/
│       │   └── datasource.yml                     # Auto-provision Prometheus datasource
│       └── dashboards/
│           └── dashboard.yml                      # Auto-load dashboards from mounted folder
├── scripts/
│   └── smoke.sh                                   # Endpoint smoke checks with curl
├── FILES_EXPLAINED.md                             # File-by-file purpose map
└── .github/
    └── workflows/
        └── pipeline.yml                           # 5-stage ready CI pipeline
```

## Optional environment overrides

```bash
cp .env.example .env
# edit values if needed
```

Docker Compose will automatically load values from `.env` in the project root.

> For local usage, set your own Grafana username and use a **strong password** (do not keep default `admin/admin`).

## Start the lab

```bash
docker compose up -d
```

## Access UIs

- Prometheus: http://localhost:9090
- Node Exporter metrics: http://localhost:9100/metrics
- Grafana: http://localhost:3000
  - Username: `admin` (or `$GRAFANA_ADMIN_USER`)
  - Password: `admin` (or `$GRAFANA_ADMIN_PASSWORD`)

## Dashboard provisioning / import

Dashboard is already provisioned automatically as:
- **Folder**: `Local Monitoring Lab`
- **Dashboard**: `Infrastructure Health`

Manual import option (if needed):
1. Open Grafana → Dashboards → New → Import.
2. Upload `grafana/dashboards/infrastructure-health.json`.
3. Select Prometheus datasource.

## Smoke validation

Run endpoint checks:

```bash
./scripts/smoke.sh
```

Optional tuning for slower environments:

```bash
SMOKE_RETRIES=30 SMOKE_SLEEP_SECONDS=2 ./scripts/smoke.sh
```

What it verifies:
- Prometheus health endpoint (`/-/healthy`)
- Node Exporter metrics endpoint (`/metrics`)
- Grafana API health endpoint (`/api/health`)

## Built-in alert

The lab ships with one simple rule:
- `NodeExporterDown`: fires when Prometheus sees `up{job="node_exporter"} == 0` for one minute.

## GitHub environment variables/secrets

For GitHub Actions, configure:
- Repository/Environment **variable**: `GRAFANA_ADMIN_USER`
- Repository/Environment **secret**: `GRAFANA_ADMIN_PASSWORD`

The pipeline passes these into Docker Compose so Grafana admin credentials come from GitHub environment configuration.

## CI pipeline (4 stages, ready to use)

Pipeline is defined in `.github/workflows/pipeline.yml` and includes:
1. **compose-validate**: `docker compose config`.
2. **lint-config**: validate Prometheus config, alert rules, dashboard JSON, and script syntax.
3. **stack-up**: start services and wait for boot.
4. **health-check**: run `scripts/smoke.sh`.
5. **alert-verify**: confirm the `NodeExporterDown` rule is loaded.

## Stop the lab

```bash
docker compose down
```
