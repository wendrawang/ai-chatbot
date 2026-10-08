#!/bin/sh
set -eu

TENCENT_SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TENCENT_BODY_FILE=$(mktemp)
TENCENT_IS_ECHO_DISABLED=false
cleanup() {
  if [ "$TENCENT_IS_ECHO_DISABLED" = true ]; then
    stty echo < /dev/tty || true
  fi
  rm -f "$TENCENT_BODY_FILE"
}
trap cleanup 0

TENCENT_MESSAGE_RANDOM=$(od -An -N4 -tu4 /dev/urandom | tr -d '[:space:]')
export TENCENT_MESSAGE_RANDOM
python3 "$TENCENT_SCRIPT_DIR/build_test_message.py" "${1:-text}" > "$TENCENT_BODY_FILE"

if [ "${TENCENT_DRY_RUN:-0}" = 1 ]; then
  cat "$TENCENT_BODY_FILE"
  exit 0
fi

if [ -z "${TENCENT_SDK_APP_ID:-}" ] || [ -z "${TENCENT_REST_HOST:-}" ]; then
  printf '%s\n' 'Set TENCENT_SDK_APP_ID and TENCENT_REST_HOST first.' >&2
  exit 2
fi

TENCENT_ADMIN_ID=${TENCENT_ADMIN_ID:-administrator}
if [ -z "${TENCENT_ADMIN_SIG:-}" ]; then
  printf '%s' 'UserSig app admin: ' >&2
  stty -echo < /dev/tty
  TENCENT_IS_ECHO_DISABLED=true
  IFS= read -r TENCENT_ADMIN_SIG < /dev/tty
  stty echo < /dev/tty
  TENCENT_IS_ECHO_DISABLED=false
  printf '\n' >&2
fi

if [ -z "$TENCENT_ADMIN_SIG" ]; then
  printf '%s\n' 'UserSig app admin must not be empty.' >&2
  exit 2
fi

case "${1:-text}" in
  create-group) TENCENT_REST_COMMAND=create_group ;;
  *) TENCENT_REST_COMMAND=send_group_msg ;;
esac
TENCENT_REQUEST_RANDOM=$(od -An -N4 -tu4 /dev/urandom | tr -d '[:space:]')
response=$(curl --silent --show-error --fail-with-body --request POST \
  --connect-timeout 10 --max-time 30 \
  --url "https://${TENCENT_REST_HOST}/v4/group_open_http_svc/${TENCENT_REST_COMMAND}" \
  --url-query "sdkappid=${TENCENT_SDK_APP_ID}" \
  --url-query "identifier=${TENCENT_ADMIN_ID}" \
  --url-query "usersig=${TENCENT_ADMIN_SIG}" \
  --url-query "random=${TENCENT_REQUEST_RANDOM}" \
  --url-query 'contenttype=json' \
  --header 'Content-Type: application/json' \
  --data-binary "@$TENCENT_BODY_FILE"
)

printf '%s\n' "$response"
printf '%s' "$response" | python3 -c '
import json, sys
try:
    reply = json.load(sys.stdin)
    is_success = (isinstance(reply, dict) and reply.get("ActionStatus") == "OK"
                  and type(reply.get("ErrorCode")) is int and reply["ErrorCode"] == 0)
except (ValueError, TypeError):
    is_success = False
if not is_success:
    sys.exit("Tencent rejected the request; inspect ErrorCode and ErrorInfo.")
'
