#!/bin/bash
set -euo pipefail

MESSAGE="$1"

BASE_DIR="/opt/blue-green"
LOG_DIR="${BASE_DIR}/logs"
DEPLOY_LOG="${LOG_DIR}/deployments.log"

mkdir -p "$LOG_DIR"

echo "$(date '+%Y-%m-%d %H:%M:%S') NOTIFY ENTER token='${TELEGRAM_BOT_TOKEN:-}' chat_id='${TELEGRAM_CHAT_ID:-}'" >> "$DEPLOY_LOG"

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${TELEGRAM_CHAT_ID:-}" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') NOTIFY SKIP missing_token_or_chat_id" >> "$DEPLOY_LOG"
  exit 0
fi

curl -s \
  -X POST \
  "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  -d text="$MESSAGE" \
  > /dev/null

echo "$(date '+%Y-%m-%d %H:%M:%S') NOTIFY SENT chat_id='${TELEGRAM_CHAT_ID}'" >> "$DEPLOY_LOG"
