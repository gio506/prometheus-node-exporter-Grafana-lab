#!/usr/bin/env bash
set -euo pipefail

PROM_URL="${PROM_URL:-http://localhost:9090/-/healthy}"
NODE_URL="${NODE_URL:-http://localhost:9100/metrics}"
GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000/api/health}"

check() {
  local name="$1"
  local url="$2"
  local extra_args="${3:-}"

  echo "[smoke] Checking ${name} -> ${url}"
  if [[ -n "${extra_args}" ]]; then
    # shellcheck disable=SC2086
    curl --fail --silent --show-error --max-time 10 ${extra_args} "${url}" >/dev/null
  else
    curl --fail --silent --show-error --max-time 10 "${url}" >/dev/null
  fi
  echo "[smoke] ${name} OK"
}

check "Prometheus health" "${PROM_URL}"
check "Node Exporter metrics" "${NODE_URL}"
check "Grafana health" "${GRAFANA_URL}" "-u admin:admin"

echo "[smoke] All endpoint checks passed."
