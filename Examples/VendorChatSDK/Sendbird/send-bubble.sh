#!/bin/sh
#
# Sends one of every bubble the package renders, as a Sendbird bot message.
#
#   APP=<application id> TOKEN=<api token> CH=<channel url> ./send-bubble.sh actions
#   ./send-bubble.sh all          sends every kind, one after another
#
# `data` has to reach Sendbird as a JSON *string*, so the payload is escaped
# by python rather than by hand - getting that wrong is the usual reason a
# card arrives as an "Update required" bubble instead.

set -eu

APP="${APP:?set APP to your Sendbird application id}"
TOKEN="${TOKEN:?set TOKEN to a Platform API token}"
CH="${CH:?set CH to the group channel url}"
BOT="${BOT:-007}"
DRY_RUN="${DRY_RUN:-0}"

send() {
  name="$1"
  fallback="$2"
  payload="$3"

  body=$(python3 -c '
import json, sys
name, fallback, payload, bot = sys.argv[1:5]
message = {"message_type": "MESG", "user_id": bot, "message": fallback}
if name:
    json.loads(payload)          # fail loudly here, not at the device
    message["custom_type"] = name
    message["data"] = payload
print(json.dumps(message))
' "$name" "$fallback" "$payload" "$BOT")

  if [ "$DRY_RUN" = "1" ]; then
    printf '%s\n' "$body"
    return
  fi

  curl -s -X POST \
    "https://api-$APP.sendbird.com/v3/group_channels/$CH/messages" \
    -H "Api-Token: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$body"
  printf '\n'
}

text() {
  send "" "Ini balasan teks biasa dengan [bold]tebal[/bold], [strike]coret[/strike], dan [color]hijau|25C36B[/color]." ""
}

actions() {
  send "content.actions" "Lanjutkan di aplikasi" '{
    "messageIdentifier": "act-1",
    "title": "Lanjutkan di aplikasi",
    "detail": "Membuka layar yang sudah ada",
    "actions": [
      { "title": "Buka transfer", "style": "primary",
        "action": { "identifier": "open-transfer",
                    "deeplink": "ocbcid://mobile?type=transfer" } },
      { "title": "Buka mutasi", "style": "secondary",
        "action": { "identifier": "open-statement",
                    "deeplink": "ocbcid://mobile?type=statement" } }
    ]
  }'
}

approval() {
  send "content.approval" "Konfirmasi transfer Anda" '{
    "messageIdentifier": "apv-1",
    "approvalIdentifier": "approval-001",
    "transactionIdentifier": "trx-001",
    "challengeIdentifier": "chl-001",
    "kind": "transfer",
    "title": "Konfirmasi transfer Anda",
    "summary": [
      { "label": "Ke", "value": "Sample Beneficiary" },
      { "label": "Jumlah", "value": "IDR 1.250.000" }
    ],
    "notice": "Otorisasi dilakukan di flow existing.",
    "expiresAt": "2099-01-01T00:00:00Z",
    "handoff": { "identifier": "handoff-transfer",
                 "deeplink": "ocbcid://mobile?type=transfer&amount=1250000" }
  }'
}

status() {
  for level in neutral success warning error; do
    send "content.status" "Status $level" '{
      "messageIdentifier": "st-'"$level"'",
      "title": "Status '"$level"'",
      "detail": "Contoh status tingkat '"$level"'.",
      "level": "'"$level"'"
    }'
  done
}

information() {
  send "content.information" "Limit transfer" '{
    "messageIdentifier": "inf-1",
    "title": "Limit transfer",
    "text": "Limit harian Anda saat ini.",
    "items": [
      { "label": "Harian", "value": "IDR 50.000.000" },
      { "label": "Terpakai", "value": "IDR 1.250.000" }
    ]
  }'
}

list() {
  send "content.financial-list" "Dana masuk" '{
    "messageIdentifier": "fl-1",
    "title": "Dana masuk",
    "style": "incoming",
    "rows": [
      { "title": "18 Jul · Gaji", "value": "+IDR 12.000.000", "tone": "positive" },
      { "title": "12 Jul · Transfer", "value": "+IDR 1.200.000", "tone": "positive" }
    ],
    "totalLabel": "Total", "totalValue": "IDR 13.200.000",
    "totalCaption": "2 transaksi",
    "footnote": "Data contoh."
  }'
}

chart() {
  send "content.chart" "Pengeluaran Juli" '{
    "messageIdentifier": "ch-1",
    "title": "Pengeluaran", "subtitle": "Juli",
    "totalValue": "IDR 8.400.000",
    "chartType": "bar",
    "series": [
      { "label": "Makan", "value": 3200000, "formattedValue": "IDR 3.200.000" },
      { "label": "Transport", "value": 1800000, "formattedValue": "IDR 1.800.000" }
    ],
    "footnote": "Data contoh."
  }'
}

portfolio() {
  send "content.portfolio" "Portofolio Anda" '{
    "messageIdentifier": "pf-1",
    "title": "Portofolio Anda",
    "totalValue": "IDR 2,45 M",
    "performanceText": "Naik 4,1% YTD",
    "allocations": [
      { "label": "Reksa dana", "value": 1200000000, "formattedValue": "IDR 1,20 M" },
      { "label": "Obligasi", "value": 800000000, "formattedValue": "IDR 0,80 M" }
    ],
    "footnote": "Kinerja masa lalu bukan jaminan."
  }'
}

receipt() {
  send "content.receipt" "Transfer berhasil" '{
    "messageIdentifier": "rc-1",
    "title": "Transfer berhasil",
    "detail": "Dana sudah terkirim.",
    "summary": [
      { "label": "Referensi", "value": "TRX-001" },
      { "label": "Jumlah", "value": "IDR 1.250.000" }
    ],
    "footnote": "Simpan sebagai bukti."
  }'
}

unsupported() {
  send "content.future-card" "Kartu jenis baru" '{
    "messageIdentifier": "unk-1",
    "fallbackText": "Perbarui aplikasi untuk melihat kartu ini."
  }'
}

case "${1:-all}" in
  text) text ;;
  actions) actions ;;
  approval) approval ;;
  status) status ;;
  information) information ;;
  list) list ;;
  chart) chart ;;
  portfolio) portfolio ;;
  receipt) receipt ;;
  unsupported) unsupported ;;
  all)
    text; actions; approval; status; information
    list; chart; portfolio; receipt; unsupported
    ;;
  *)
    echo "kinds: text actions approval status information list chart portfolio receipt unsupported all"
    exit 1
    ;;
esac
