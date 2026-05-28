#!/bin/bash

BASE_DIR="${RUNTIME_PATH:-/opt/blue-green}"
COMPOSE_DIR="${BASE_DIR}/compose"
STATE_DIR="${BASE_DIR}/state"
LOG_DIR="${BASE_DIR}/logs"
NGINX_TEMPLATE="${BASE_DIR}/nginx/templates/blue-green.conf.template"
NGINX_GENERATED="${BASE_DIR}/nginx/generated/blue-green.conf"
NGINX_TARGET="/etc/nginx/conf.d/blue-green.conf"
LOCK_FILE="${STATE_DIR}/deploy.lock"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${LOG_DIR}/deployments.log"
}

health_log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${LOG_DIR}/healthchecks.log"
}

rollback_log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "${LOG_DIR}/rollback.log"
}

get_active_slot() {
  cat "${STATE_DIR}/active_slot"
}

get_inactive_slot() {
  ACTIVE_SLOT="$(get_active_slot)"

  if [ "$ACTIVE_SLOT" = "slot-a" ]; then
    echo "slot-b"
  else
    echo "slot-a"
  fi
}

get_slot_port() {
  SLOT="$1"

  case "$SLOT" in
    slot-a)
      echo 8000
      ;;
    slot-b)
      echo 8001
      ;;
    *)
      echo "Unknown slot: ${SLOT}" >&2
      exit 1
      ;;
  esac
}

get_slot_service() {
  SLOT="$1"

  case "$SLOT" in
    slot-a)
      echo "app-slot-a"
      ;;
    slot-b)
      echo "app-slot-b"
      ;;
    *)
      echo "Unknown slot: ${SLOT}" >&2
      exit 1
      ;;
  esac
}

get_slot_env_key() {
  SLOT="$1"

  case "$SLOT" in
    slot-a)
      echo "IMAGE_A"
      ;;
    slot-b)
      echo "IMAGE_B"
      ;;
    *)
      echo "Unknown slot: ${SLOT}" >&2
      exit 1
      ;;
  esac
}
