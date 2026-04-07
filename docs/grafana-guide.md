# Grafana Dashboard Guide

Notes on the infrastructure-health dashboard: what each panel shows and how to read it.

## Dashboard: Infrastructure Health

Located at: `grafana/dashboards/infrastructure-health.json`

### Panel: CPU Usage

**Query**: `(1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))) * 100`

This shows the percentage of CPU time **not** spent idle, averaged across all cores. A single spike is normal — sustained > 80% for more than 5 minutes warrants investigation.

**Reading it**:
- 0–50%: Healthy
- 50–80%: Increased load, monitor
- 80%+: Alert threshold — check which process is consuming CPU

---

### Panel: Memory Available

**Query**: `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100`

Shows the percentage of RAM that is immediately available (free + buffered + cached pages that can be reclaimed).

**Common confusion**: This is `MemAvailable`, not `MemFree`. Linux aggressively uses RAM for file cache — `MemFree` is low even on healthy systems. `MemAvailable` is the right metric.

---

### Panel: Disk I/O

**Query**: `rate(node_disk_io_time_seconds_total[5m]) * 100`

Shows how busy the disk is (% of time actively doing I/O). Consistently above 90% indicates the disk is saturated.

---

### Panel: Network In/Out

**Queries**:
- In: `rate(node_network_receive_bytes_total{device!="lo"}[5m]) * 8`
- Out: `rate(node_network_transmit_bytes_total{device!="lo"}[5m]) * 8`

Multiplied by 8 to convert bytes → bits per second. The `{device!="lo"}` filter excludes the loopback interface.

---

## Adding a New Panel

1. Open Grafana at `http://localhost:3000`
2. Navigate to the dashboard → ⚙ Edit
3. Add panel → choose Metrics → enter PromQL
4. Export JSON: Dashboard settings → JSON Model → copy and save to `grafana/dashboards/`

**Important**: Always save the JSON back to the repo. The dashboard is provisioned from file on startup — anything configured only in the UI will be lost on container restart.

---

## Useful PromQL Cheatsheet

```promql
# Average rate over 5 minutes
rate(metric[5m])

# Percentage of something
(value / total) * 100

# Compare against threshold
metric > 0.85

# Filter by label
metric{label="value"}

# Aggregate across instances (not needed in single-node lab)
avg by (instance) (metric)

# Detect if something is down (0 = not scraped = down)
up{job="node-exporter"} == 0
```
