#!/usr/bin/env bash
set -euo pipefail

PROM_URL="${PROM_URL:-http://localhost:9090/-/healthy}"
NODE_URL="${NODE_URL:-http://localhost:9100/metrics}"
GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000/api/health}"
GRAFANA_USER="${GRAFANA_USER:-admin}"
GRAFANA_PASSWORD="${GRAFANA_PASSWORD:-admin}"
RETRIES="${SMOKE_RETRIES:-20}"
SLEEP_SECONDS="${SMOKE_SLEEP_SECONDS:-3}"

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "[smoke] Required command not found: $cmd" >&2
    exit 1
  }
}

check_with_retry() {
  local name="$1"
  local url="$2"
  local auth_userpass="${3:-}"
  local attempt=1

  while (( attempt <= RETRIES )); do
    echo "[smoke] ${name} (attempt ${attempt}/${RETRIES}) -> ${url}"

    if [[ -n "$auth_userpass" ]]; then
      if curl --fail --silent --show-error --max-time 10 -u "$auth_userpass" "$url" >/dev/null; then
        echo "[smoke] ${name} OK"
        return 0
      fi
    else
      if curl --fail --silent --show-error --max-time 10 "$url" >/dev/null; then
        echo "[smoke] ${name} OK"
        return 0
      fi
    fi

    if (( attempt < RETRIES )); then
      sleep "$SLEEP_SECONDS"
    fi

    ((attempt++))
  done

  echo "[smoke] ${name} FAILED after ${RETRIES} attempts" >&2
  return 1
}

require_cmd curl

check_with_retry "Prometheus health" "$PROM_URL"
check_with_retry "Node Exporter metrics" "$NODE_URL"
check_with_retry "Grafana health" "$GRAFANA_URL" "${GRAFANA_USER}:${GRAFANA_PASSWORD}"

echo "[smoke] All endpoint checks passed."
