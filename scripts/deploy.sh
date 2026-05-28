#!/bin/bash
set -euo pipefail

source /opt/blue-green/scripts/common.sh

VERSION="$1"
IMAGE="$2"

mkdir -p "$LOG_DIR" "${STATE_DIR}/deploy-history" "${BASE_DIR}/tmp"
touch "$LOG_DIR/deployments.log"

exec 200>"$LOCK_FILE"

echo "Waiting for deployment lock..."
flock 200

START_TS="$(date +%s)"

notify() {
  /opt/blue-green/scripts/notify.sh "$1" || true
}

on_error() {
  EXIT_CODE="$?"

  log "DEPLOY FAILED version=${VERSION} image=${IMAGE} exit_code=${EXIT_CODE}"

  notify "Deploy failed
Version: ${VERSION}
Image: ${IMAGE}
Exit code: ${EXIT_CODE}"

  exit "$EXIT_CODE"
}

trap on_error ERR

ACTIVE_SLOT="$(get_active_slot)"
TARGET_SLOT="$(get_inactive_slot)"
TARGET_PORT="$(get_slot_port "$TARGET_SLOT")"
TARGET_SERVICE="$(get_slot_service "$TARGET_SLOT")"
TARGET_ENV_KEY="$(get_slot_env_key "$TARGET_SLOT")"

log "DEPLOY START version=${VERSION} image=${IMAGE} active=${ACTIVE_SLOT} target=${TARGET_SLOT}"

log "PULL IMAGE image=${IMAGE}"

docker pull "$IMAGE"

TMP_ENV="${BASE_DIR}/tmp/slots.env.$$"

cp "${STATE_DIR}/slots.env" "$TMP_ENV"

if grep -q "^${TARGET_ENV_KEY}=" "$TMP_ENV"; then
  sed -i "s|^${TARGET_ENV_KEY}=.*|${TARGET_ENV_KEY}=${IMAGE}|g" "$TMP_ENV"
else
  echo "${TARGET_ENV_KEY}=${IMAGE}" >> "$TMP_ENV"
fi

docker compose \
  -p "${COMPOSE_PROJECT_NAME}" \
  --env-file "$TMP_ENV" \
  -f "${COMPOSE_DIR}/docker-compose.yaml" \
  up -d "$TARGET_SERVICE"

"${BASE_DIR}/scripts/healthcheck.sh" "$TARGET_PORT"

"${BASE_DIR}/scripts/switch.sh" "$TARGET_SLOT"

mv "$TMP_ENV" "${STATE_DIR}/slots.env"

echo "$VERSION" > "${STATE_DIR}/${TARGET_SLOT}.version"

END_TS="$(date +%s)"
DURATION="$((END_TS - START_TS))"

cat > "${STATE_DIR}/deploy-history/${VERSION}.json" <<EOF
{
  "version": "${VERSION}",
  "image": "${IMAGE}",
  "slot": "${TARGET_SLOT}",
  "status": "success",
  "duration_seconds": ${DURATION},
  "created_at": "$(date -Iseconds)"
}
EOF

log "DEPLOY SUCCESS version=${VERSION} image=${IMAGE} slot=${TARGET_SLOT} duration=${DURATION}s"

notify "Deploy successful
Version: ${VERSION}
Slot: ${TARGET_SLOT}
Image: ${IMAGE}
Duration: ${DURATION}s"

trap - ERR
