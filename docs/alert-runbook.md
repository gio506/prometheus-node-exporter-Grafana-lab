# Prometheus Alert Runbook

Actionable responses for alerts fired by this monitoring lab.

---

## NodeExporterDown

**Alert definition**: `up{job="node-exporter"} == 0` for 1 minute

### What it means

The Node Exporter process on the monitored host is not responding. Prometheus can't scrape metrics.

### Investigation steps

```bash
# 1. Check if the container is running
docker compose ps node-exporter

# 2. Check container logs for crash reason
docker compose logs --tail=50 node-exporter

# 3. Check if port 9100 is bound
docker compose exec node-exporter ss -tlnp | grep 9100

# 4. Try direct scrape to verify reachability
curl http://localhost:9100/metrics | head -20
```

### Resolution

```bash
# Restart the exporter
docker compose restart node-exporter

# Verify it comes back
curl http://localhost:9100/metrics | grep node_cpu_seconds_total | head -3
```

**Escalate if**: Exporter restarts repeatedly. Could indicate the host is resource-starved or Docker daemon issues.

---

## HighCPU

**Alert definition**: `(1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))) > 0.85` for 5 minutes

### What it means

CPU utilization is above 85% for more than 5 minutes. The system may be struggling.

### Investigation steps

```bash
# Check which process is burning CPU on the host
# (inside the node-exporter host or docker host)
top -b -n 1 | head -20

# Check if it's a specific Docker container
docker stats --no-stream
```

---

## High Memory Pressure

**Alert definition**: `(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) < 0.10` for 2 minutes

### What it means

Less than 10% of physical RAM is available. The kernel may start swapping.

```bash
# Check memory breakdown
free -h

# Find top memory consumers
docker stats --no-stream --format "{{.Name}}\t{{.MemUsage}}"
```

---

## Grafana Not Responding

If the Grafana dashboard isn't loading:

```bash
# Check container health
docker compose ps grafana

# Check Grafana logs for startup errors
docker compose logs --tail=100 grafana | grep -i "error\|fatal\|warn"

# Restart Grafana (stateless — dashboards are provisioned from files)
docker compose restart grafana

# Verify it's back
curl -s http://localhost:3000/api/health | python3 -m json.tool
```
