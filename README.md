# Prometheus + Node Exporter + Grafana (Local Monitoring Lab)

Intermediate monitoring lab to observe local infrastructure metrics quickly using Docker Compose.

## What you will run

- **Prometheus** for metrics collection and querying.
- **Node Exporter** for host-level metrics.
- **Grafana** for dashboard visualization (auto-provisioned).

## Project tree (with short explanation)

```text
.
├── docker-compose.yml                             # Runs Prometheus, Node Exporter, Grafana
├── README.md                                      # Lab setup + usage guide
├── CHEATSHEET.md                                  # Fast commands + troubleshooting + query references
├── prometheus/
│   └── prometheus.yml                             # Prometheus scrape configuration
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
└── .github/
    └── workflows/
        └── pipeline.yml                           # 4-stage ready CI pipeline
```

## Start the lab

```bash
docker compose up -d
```

## Access UIs

- Prometheus: http://localhost:9090
- Node Exporter metrics: http://localhost:9100/metrics
- Grafana: http://localhost:3000
  - Username: `admin`
  - Password: `admin`

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

What it verifies:
- Prometheus health endpoint (`/-/healthy`)
- Node Exporter metrics endpoint (`/metrics`)
- Grafana API health endpoint (`/api/health`)

## CI pipeline (4 stages, ready to use)

Pipeline is defined in `.github/workflows/pipeline.yml` and includes:
1. **compose-validate**: `docker compose config`.
2. **stack-up**: start services and wait for boot.
3. **health-check**: run `scripts/smoke.sh`.
4. **lint-config**: validate Prometheus config + dashboard JSON + script syntax.

## Stop the lab

```bash
docker compose down
```
