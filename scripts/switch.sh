#!/bin/bash
set -euo pipefail

source /opt/blue-green/scripts/common.sh

TARGET_SLOT="$1"
TARGET_PORT="$(get_slot_port "$TARGET_SLOT")"

log "SWITCH START target_slot=${TARGET_SLOT} target_port=${TARGET_PORT}"

sed "s/{{PORT}}/${TARGET_PORT}/g" \
  "$NGINX_TEMPLATE" \
  > "$NGINX_GENERATED"

sudo cp "$NGINX_GENERATED" "$NGINX_TARGET"

sudo nginx -t

sudo systemctl reload nginx

echo "$TARGET_SLOT" > "${STATE_DIR}/active_slot"

log "SWITCH SUCCESS active_slot=${TARGET_SLOT} port=${TARGET_PORT}"
