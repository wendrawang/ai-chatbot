# JSON untuk menghasilkan bubble

Package menerima **nama event + payload JSON** melalui `TanyaAIChatSession`.
Backend tidak mengirim nama SwiftUI view. Nama event memilih bubble; payload
mengisi teks, nilai, pilihan, atau tombolnya.

## Contoh paling sederhana: status

```json
{
  "event": "content.status",
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
onEvent?(.structuredPayload(name: "content.status", json: payload))
onEvent?(.messageCompleted(messageIdentifier: "status-1"))
```

Jangan meneruskan seluruh envelope sebagai `json:`. Package membutuhkan field
`messageIdentifier` langsung di root payload, bukan di dalam `data` lagi.

## Pilih bubble

Setiap tautan berisi payload lengkap, field wajib, dan perilakunya.

| Tampilan | Event | Referensi |
| --- | --- | --- |
| Teks | `text.delta` | Contoh streaming di bawah |
| Gambar + caption | `content.image` | [Gambar](bubbles/CONTENT.md#contentimage) |
| Pilihan + submit | `content.choices` | [Choices](bubbles/CONTENT.md#contentchoices) |
| Tombol deeplink | `content.actions` | [Actions](bubbles/CONTENT.md#contentactions) |
| HTML statis | `content.html` | [HTML](bubbles/CONTENT.md#contenthtml) |
| Penawaran agen | `content.live-agent` | [Live agent](bubbles/CONTENT.md#contentlive-agent) |
| Konfirmasi + PIN/hand-off | `content.approval` | [Approval](bubbles/FINANCIAL.md#contentapproval) |
| Bukti transaksi | `content.receipt` | [Receipt](bubbles/FINANCIAL.md#contentreceipt) |
| Chart | `content.chart` | [Chart](bubbles/FINANCIAL.md#contentchart) |
| Portfolio | `content.portfolio` | [Portfolio](bubbles/FINANCIAL.md#contentportfolio) |
| Daftar keuangan | `content.financial-list` | [Financial list](bubbles/FINANCIAL.md#contentfinancial-list) |
| Status proses | `content.status` | [Status](bubbles/INFORMATION.md#contentstatus) |
| Teks + label/value | `content.information` | [Information](bubbles/INFORMATION.md#contentinformation) |
| Saran, satu tap langsung kirim | `response.suggestions` | [Suggestions](bubbles/INFORMATION.md#responsesuggestions) |
| Jenis belum dikenal | `content.*` | [Fallback](bubbles/INFORMATION.md#contentfuture) |

File siap dibaca backend tersedia di [Examples/BubbleResponses](../Examples/BubbleResponses/).
[conversation.json](../Examples/BubbleResponses/conversation.json) berisi contoh
satu balasan lengkap: mulai → teks → status → suggestions → selesai. Array tersebut
adalah fixture; adapter harus meneruskan event satu per satu sesuai urutan.

## Teks dan streaming

```json
[
  {"event":"response.started","data":{"messageIdentifier":"text-1"}},
  {"event":"text.delta","data":{"messageIdentifier":"text-1","text":"Saldo Anda "}},
  {"event":"text.delta","data":{"messageIdentifier":"text-1","text":"[bold]IDR 12.500.000[/bold]."}},
  {"event":"response.completed","data":{"messageIdentifier":"text-1"}}
]
```

Identifier yang sama membuat delta bergabung pada satu bubble. Untuk bubble baru,
gunakan identifier baru. Konten dengan identifier sama memperbarui bubble tersebut;
ada pengecualian untuk approval yang sudah selesai agar catatannya tidak ditimpa.

Adapter harus memetakan event lifecycle ke enum session yang tepat:

| Event backend | Emit dari adapter |
| --- | --- |
| `response.started` | `.messageStarted(messageIdentifier: ...)` |
| `text.delta` | `.messageDelta(messageIdentifier: ..., text: ...)` |
| `response.completed` | `.messageCompleted(messageIdentifier: ...)` |
| `content.*` | `.structuredPayload(name: ..., json: payloadData)` |
| `response.suggestions` | `.structuredPayload(name: "response.suggestions", json: payloadData)` |
| `heartbeat` | `.structuredPayload(name: "heartbeat", json: Data("{}".utf8))` |

Khusus completion, gunakan `.messageCompleted`, bukan sekadar structured payload
bernama `response.completed`, agar repository ikut menutup request aktif.
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
  "custom_type": "content.status",
  "message": "Permintaan selesai",
  "data": "{\"messageIdentifier\":\"status-1\",\"title\":\"Selesai\",\"detail\":\"Sudah diproses.\",\"level\":\"success\"}"
}
```

Ini contoh body pesan, bukan endpoint lengkap untuk mengirim ke vendor. Backend
sebaiknya memakai serializer JSON untuk mengisi `data`, bukan menyusun escape
secara manual. `message` berguna untuk dashboard/notifikasi; pada typed bubble,
aplikasi merender `data` dan tidak memakai `message` sebagai fallback.

Adapter contoh saat ini hanya meneruskan `custom_type` berawalan `content.` dan
mengakhiri turn setelah setiap pesan utuh. Teks biasa dipetakan menjadi satu delta
lalu completion. **`response.suggestions` dan streaming multi-event memerlukan
mapping tambahan pada adapter Sendbird**; jangan menganggap tabel lifecycle di
atas otomatis berlaku pada adapter tersebut. Format inbound typed card 3Dolphins
belum terverifikasi; pakai mock dahulu untuk review semua bubble.

## Aturan payload agar stabil dan ringan

- Gunakan identifier stabil dan unik untuk bubble yang berbeda.
- Field wajib harus ada. Array kosong boleh pada kontrak yang mengizinkannya;
  optional dapat dihilangkan. Enum tidak dikenal memiliki fallback, tetapi field
  wajib yang hilang tetap gagal decode.
- Payload rusak menjadi bubble unsupported; `content.*` baru dapat membawa
  `fallbackText`. Event di luar nama yang dikenal dan prefix content diabaikan.
- Kirim URL gambar, bukan base64. Sertakan aspectRatio yang benar. Hindari HTML
  untuk tampilan yang sudah memiliki bubble native.
- Nilai numerik chart menentukan proporsi; `formattedValue` menentukan label.
- Pertahankan typed payload di history agar kartu dapat dipulihkan. Package
  mempertahankan 100 pesan terbaru, tetapi host tetap perlu membatasi ukuran
  payload dari backend sesuai kebutuhan produknya.
- Payload approval berisi challenge/expiry, bukan PIN atau token autentikasi.
