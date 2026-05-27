#!/bin/bash
set -euo pipefail

source /opt/blue-green/scripts/common.sh

PORT="$1"
URL="http://127.0.0.1:${PORT}/inner/healthcheck"

health_log "HEALTHCHECK START url=${URL}"

for i in {1..30}; do
  if curl -fs "$URL" > /dev/null; then
    health_log "HEALTHCHECK SUCCESS url=${URL} attempt=${i}"
    exit 0
  fi

  health_log "HEALTHCHECK FAILED_ATTEMPT url=${URL} attempt=${i}/30"
  sleep 2
done

health_log "HEALTHCHECK FAILED url=${URL}"
exit 1
