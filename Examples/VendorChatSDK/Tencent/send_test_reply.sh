#!/bin/sh
set -eu

if [ -z "${TENCENT_SDK_APP_ID:-}" ] || [ -z "${TENCENT_REST_HOST:-}" ]; then
  printf '%s\n' 'Set TENCENT_SDK_APP_ID and TENCENT_REST_HOST first.' >&2
  exit 2
fi

TENCENT_ADMIN_ID=${TENCENT_ADMIN_ID:-administrator}

if [ -z "${TENCENT_ADMIN_SIG:-}" ]; then
  printf '%s' 'UserSig app admin: ' >&2
  stty -echo < /dev/tty
  trap 'stty echo < /dev/tty' 0
  IFS= read -r TENCENT_ADMIN_SIG < /dev/tty
  stty echo < /dev/tty
  trap - 0
  printf '\n' >&2
fi

if [ -z "$TENCENT_ADMIN_SIG" ]; then
  printf '%s\n' 'UserSig app admin must not be empty.' >&2
  exit 2
fi

TENCENT_REQUEST_RANDOM=$(od -An -N4 -tu4 /dev/urandom | tr -d '[:space:]')
TENCENT_MESSAGE_RANDOM=$(od -An -N4 -tu4 /dev/urandom | tr -d '[:space:]')

TENCENT_SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TENCENT_BODY_FILE=$(mktemp)
trap 'rm -f "$TENCENT_BODY_FILE"' 0
export TENCENT_MESSAGE_RANDOM
python3 "$TENCENT_SCRIPT_DIR/build_test_message.py" "${1:-text}" > "$TENCENT_BODY_FILE"

response=$(curl --silent --show-error --fail-with-body --request POST \
  --url "https://${TENCENT_REST_HOST}/v4/openim/sendmsg" \
  --url-query "sdkappid=${TENCENT_SDK_APP_ID}" \
  --url-query "identifier=${TENCENT_ADMIN_ID}" \
  --url-query "usersig=${TENCENT_ADMIN_SIG}" \
  --url-query "random=${TENCENT_REQUEST_RANDOM}" \
  --url-query 'contenttype=json' \
  --header 'Content-Type: application/json' \
  --data-binary "@$TENCENT_BODY_FILE"
)

printf '%s\n' "$response"
if ! printf '%s' "$response" | grep -Eq '"ActionStatus"[[:space:]]*:[[:space:]]*"OK"' ||
   ! printf '%s' "$response" | grep -Eq '"ErrorCode"[[:space:]]*:[[:space:]]*0'; then
  printf '%s\n' 'Tencent rejected the message; inspect ErrorCode and ErrorInfo.' >&2
  exit 1
fi
