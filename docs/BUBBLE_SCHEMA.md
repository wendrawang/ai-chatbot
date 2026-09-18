# JSON untuk menghasilkan bubble

Package menerima **nama event + payload JSON** melalui `TanyaAIChatSession`.
Backend tidak mengirim nama SwiftUI view. Nama event memilih bubble; payload
mengisi teks, nilai, pilihan, atau tombolnya.

## Contoh paling sederhana: status

```json
{
  "event": "status",
  "data": {
    "messageIdentifier": "status-1",
    "title": "Selesai",
    "detail": "Permintaan Anda sudah diproses.",
    "level": "success"
  }
}
```

`event` + `data` adalah **envelope contoh yang netral terhadap vendor**, bukan
endpoint atau format yang otomatis diparse package. Adapter host mengambil nama
`event` dan mengubah **objek data saja** menjadi `Data`, lalu meneruskannya:

```swift
let payload = Data("""
{
  "messageIdentifier": "status-1",
  "title": "Selesai",
  "detail": "Sudah diproses.",
  "level": "success"
}
""".utf8)
onEvent?(.structuredPayload(name: "status", json: payload))
onEvent?(.messageCompleted(messageIdentifier: "status-1"))
```

Jangan meneruskan seluruh envelope sebagai `json:`. Package membutuhkan field
`messageIdentifier` langsung di root payload, bukan di dalam `data` lagi.

## Pilih bubble

Setiap tautan berisi payload lengkap, field wajib, dan perilakunya.

| Tampilan | Event | Referensi |
| --- | --- | --- |
| Teks | `text_delta` | Contoh streaming di bawah |
| Gambar + caption | `image` | [Gambar](bubbles/CONTENT.md#image) |
| Pilihan + submit | `choices` | [Choices](bubbles/CONTENT.md#choices) |
| Tombol deeplink | `actions` | [Actions](bubbles/CONTENT.md#actions) |
| HTML statis | `html` | [HTML](bubbles/CONTENT.md#html) |
| Penawaran agen | `live_agent` | [Live agent](bubbles/CONTENT.md#live_agent) |
| Konfirmasi + PIN/hand-off | `approval` | [Approval](bubbles/FINANCIAL.md#approval) |
| Bukti transaksi | `receipt` | [Receipt](bubbles/FINANCIAL.md#receipt) |
| Chart | `chart` | [Chart](bubbles/FINANCIAL.md#chart) |
| Portfolio | `portfolio` | [Portfolio](bubbles/FINANCIAL.md#portfolio) |
| Daftar keuangan | `financial_list` | [Financial list](bubbles/FINANCIAL.md#financial_list) |
| Status proses | `status` | [Status](bubbles/INFORMATION.md#status) |
| Teks + label/value | `information` | [Information](bubbles/INFORMATION.md#information) |
| Saran, satu tap langsung kirim | `suggestions` | [Suggestions](bubbles/INFORMATION.md#suggestions) |
| Jenis belum dikenal | nama baru, misalnya `future_card` | [Fallback](bubbles/INFORMATION.md#future_card) |

File siap dibaca backend tersedia di [Examples/BubbleResponses](../Examples/BubbleResponses/).
[conversation.json](../Examples/BubbleResponses/conversation.json) berisi contoh
satu balasan lengkap: mulai → teks → status → suggestions → selesai. Array tersebut
adalah fixture; adapter harus meneruskan event satu per satu sesuai urutan.

## Teks dan streaming

```json
[
  {"event":"response_started","data":{"messageIdentifier":"text-1"}},
  {"event":"text_delta","data":{"messageIdentifier":"text-1","text":"Saldo Anda "}},
  {"event":"text_delta","data":{"messageIdentifier":"text-1","text":"[bold]IDR 12.500.000[/bold]."}},
  {"event":"response_completed","data":{"messageIdentifier":"text-1"}}
]
```

Identifier yang sama membuat delta bergabung pada satu bubble. Untuk bubble baru,
gunakan identifier baru. Konten dengan identifier sama memperbarui bubble tersebut;
ada pengecualian untuk approval yang sudah selesai agar catatannya tidak ditimpa.

Adapter harus memetakan event lifecycle ke enum session yang tepat:

| Event backend | Emit dari adapter |
| --- | --- |
| `response_started` | `.messageStarted(messageIdentifier: ...)` |
| `text_delta` | `.messageDelta(messageIdentifier: ..., text: ...)` |
| `response_completed` | `.messageCompleted(messageIdentifier: ...)` |
| Nama bubble pada katalog atau tipe baru | `.structuredPayload(name: ..., json: payloadData)` |
| `suggestions` | `.structuredPayload(name: "suggestions", json: payloadData)` |
| `heartbeat` | `.structuredPayload(name: "heartbeat", json: Data("{}".utf8))` |

Khusus completion, gunakan `.messageCompleted`, bukan sekadar structured payload
bernama `response_completed`, agar repository ikut menutup request aktif.
Kirim suggestions sebelum completion untuk satu balasan terurut. Jika SDK mengirim
pesan utuh, satu `.messageDelta` cukup. Jangan mengirim ulang seluruh teks sebagai
delta karena akan terduplikasi. Error transport dikirim sebagai `.failed(error)`.

Styling teks memakai tag berikut, bukan Markdown:

| Tag | Hasil |
| --- | --- |
| `[bold]teks[/bold]` | Tebal |
| `[italic]teks[/italic]` | Miring |
| `[underline]teks[/underline]` | Garis bawah |
| `[strike]teks[/strike]` | Coret |
| `[color]teks\|25C36B[/color]` | Warna hex |

Tag dapat bersarang. Tag tidak dikenal dibuang, teksnya dipertahankan.

## Kalau memakai Sendbird

Contoh adapter Sendbird memakai `custom_type` untuk nama bubble dan `data` berupa
**string JSON**, sesuai bentuk field yang dibaca adapter:

```json
{
  "message_type": "MESG",
  "user_id": "bot-user-id",
  "custom_type": "status",
  "message": "Permintaan selesai",
  "data": "{\"messageIdentifier\":\"status-1\",\"title\":\"Selesai\",\"detail\":\"Sudah diproses.\",\"level\":\"success\"}"
}
```

Ini contoh body pesan, bukan endpoint lengkap untuk mengirim ke vendor. Backend
sebaiknya memakai serializer JSON untuk mengisi `data`, bukan menyusun escape
secara manual. `message` berguna untuk dashboard/notifikasi; pada typed bubble,
aplikasi merender `data` dan tidak memakai `message` sebagai fallback.

Adapter Sendbird contoh memakai `TanyaAIChatSessionEvent.fromWire(name:json:)`
untuk nama di katalog, termasuk suggestions dan lifecycle streaming. Card utuh
langsung diikuti completion; streaming selesai hanya ketika `response_completed`
diterima. Event kontrol tidak dipulihkan sebagai kartu history; backend harus
menyimpan hasil teks utuh, bukan menjadikan setiap delta sebagai pesan history.
Format inbound typed card 3Dolphins belum terverifikasi; pakai mock untuk review.

## Nama unik tanpa titik

Nama canonical memakai huruf kecil dan underscore untuk dua kata. Seluruh 17 nama
terdaftar di `TanyaAIEventName` (tersedia melalui `import TanyaAI`). Gunakan
`TanyaAIEventName.status.rawValue` ketika tidak ingin menulis string manual.

- Bubble: `image`, `choices`, `actions`, `html`, `live_agent`, `approval`, `receipt`,
  `chart`, `portfolio`, `financial_list`, `status`, `information`.
- Saran: `suggestions`.
- Lifecycle: `response_started`, `text_delta`, `response_completed`, `heartbeat`.

Nama lama seperti `content.status` dan `response.completed` hanya alias untuk
membaca payload/history lama. Payload dan contoh baru memakai nama tanpa titik.
Kompatibilitas satu arah: app baru membaca format lama; app versi lama belum
tentu memahami format baru. Sesuaikan rollout backend dengan versi client.
Nama baru yang belum dikenal, misalnya `future_card`, menampilkan fallback apabila
payload membawa `messageIdentifier`. Nama kontrol bertitik yang tidak dikenal
diabaikan. Seluruh custom_type non-kosong pada kanal fitur dianggap milik kontrak
ini, jadi jangan mencampurkan tipe metadata vendor lain ke field tersebut.

Untuk adapter sendiri, gunakan satu fungsi pemetaan:

```swift
let event = try TanyaAIChatSessionEvent.fromWire(name: name, json: payloadData)
onEvent?(event)
```

Fungsi tersebut mengubah lifecycle ke enum native sehingga completion juga
membersihkan request repository. Error payload lifecycle perlu diteruskan sebagai
`.failed(error)`. Adapter pesan utuh menambahkan `.messageCompleted(...)` setelah
card; adapter streaming mengikuti event completion dari backend.

## Aturan payload agar stabil dan ringan

- Gunakan identifier stabil dan unik untuk bubble yang berbeda.
- Field wajib harus ada. Array kosong boleh pada kontrak yang mengizinkannya;
  optional dapat dihilangkan. Enum tidak dikenal memiliki fallback, tetapi field
  wajib yang hilang tetap gagal decode.
- Payload rusak menjadi bubble unsupported; nama baru, misalnya `future_card` baru dapat membawa
  `fallbackText`. Event di luar nama yang dikenal dan prefix content diabaikan.
- Kirim URL gambar, bukan base64. Sertakan aspectRatio yang benar. Hindari HTML
  untuk tampilan yang sudah memiliki bubble native.
- Nilai numerik chart menentukan proporsi; `formattedValue` menentukan label.
- Pertahankan typed payload di history agar kartu dapat dipulihkan. Package
  mempertahankan 100 pesan terbaru, tetapi host tetap perlu membatasi ukuran
  payload dari backend sesuai kebutuhan produknya.
- Payload approval berisi challenge/expiry, bukan PIN atau token autentikasi.
