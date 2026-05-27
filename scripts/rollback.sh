#!/bin/bash
set -euo pipefail

source /opt/blue-green/scripts/common.sh

exec 200>"$LOCK_FILE"

echo "Waiting for deployment lock..."
flock 200

ACTIVE_SLOT="$(get_active_slot)"

if [ "$ACTIVE_SLOT" = "slot-a" ]; then
  TARGET_SLOT="slot-b"
else
  TARGET_SLOT="slot-a"
fi

TARGET_PORT="$(get_slot_port "$TARGET_SLOT")"
TARGET_VERSION="$(cat "${STATE_DIR}/${TARGET_SLOT}.version")"

rollback_log "ROLLBACK START from=${ACTIVE_SLOT} to=${TARGET_SLOT} version=${TARGET_VERSION}"

"${BASE_DIR}/scripts/healthcheck.sh" "$TARGET_PORT"

"${BASE_DIR}/scripts/switch.sh" "$TARGET_SLOT"

rollback_log "ROLLBACK SUCCESS active_slot=${TARGET_SLOT} version=${TARGET_VERSION}"
