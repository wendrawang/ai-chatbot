# Vendor chat SDK sebagai transport

Dipakai ketika percakapan dijalankan oleh SDK live chat vendor (mis. 3Dolphins
Live Chat SDK untuk Swift), tetapi tampilan chat tetap milik aplikasi Anda:
bubble bertipe, kartu approval, PIN sheet, dan hand-off deeplink tidak berubah.

## Yang berubah dan yang tidak

| Lapisan | Berubah? |
| --- | --- |
| `TanyaAIPresentation` (semua bubble & layar) | Tidak |
| `TanyaAI` (router, PIN sheet, hand-off) | Tidak |
| Repository | Dipilih otomatis: `TanyaAISessionRepository` saat sesi vendor diinjeksi |
| Transport | `TanyaAIStreamingTransport` (SSE) **atau** `TanyaAIChatSession` (vendor) |
| Adapter vendor | Baru - satu file di aplikasi Anda, contohnya di folder ini |

Cara memasangnya cuma berbeda satu baris di composition root:

```swift
let dependencies = TanyaAIDependencies(
    chatSession: VendorChatSessionAdapter(
        client: DolphinLiveChatClient(...),
        userToken: session.token
    ),
    authorizationService: AppTanyaAIAuthorization(),
    theme: .app
)
```

## Yang harus Anda isi

`VendorChatSessionAdapter.swift` di folder ini memakai **placeholder** untuk
tipe SDK vendor (`VendorLiveChatClient`, `VendorMessage`, dan delegate-nya).
Hapus placeholder itu, `import` modul vendor, lalu isi lima titik berikut:

| Titik | Isi |
| --- | --- |
| `connect()` | Panggil koneksi SDK, termasuk token/otentikasi nasabah |
| `send(text:requestIdentifier:)` | Panggil pengiriman pesan SDK |
| Callback pesan masuk | Petakan ke `messageStarted` / `messageDelta` / `messageCompleted` |
| Callback payload kaya | Petakan ke `structuredPayload(name:json:)` |
| Callback error & disconnect | Petakan ke `failed` / `disconnected` |

Catatan jujur: dokumentasi SDK vendor tidak bisa diakses dari lingkungan tempat
kode ini disusun (domainnya diblokir proxy), jadi nama kelas dan delegate di
file contoh **bukan** nama asli SDK 3Dolphins. Strukturnya yang relevan, bukan
simbolnya.

## Kontrak dengan tim bot

Agar kartu bertipe tetap hidup, bot mengirim JSON yang sama seperti pada SSE,
dibungkus amplop dua kunci lewat payload kaya milik vendor:

```json
{ "event": "content.actions", "data": { "...": "..." } }
```

`data` diteruskan apa adanya ke paket - jangan dimodelkan ulang di adapter.
Skema tiap `event` ada di [`docs/BUBBLE_SCHEMA.md`](../../docs/BUBBLE_SCHEMA.md).

Untuk hand-off yang didorong kanal (bukan tombol di kartu), kirim payload
berisi `deeplink`; adapter mengubahnya jadi `hostAction`, dan paket
meneruskannya ke handler `onAction` yang sama dengan tombol kartu. Jadi apa pun
sumber aksinya, aplikasi Anda hanya punya satu pintu keluar.

## Menguji tanpa SDK

`MockTanyaAIChatSession` di `TanyaAITestSupport` menggantikan SDK vendor:

```swift
TanyaAIDependencies(
    chatSession: MockTanyaAIChatSession.demo(
        deeplink: "ocbcid://mobile?type=transfer"
    ),
    authorizationService: MockTanyaAIAuthorizationService(),
    theme: .sandbox
)
```

`.demo(deeplink:)` mengirim typing, teks, dan kartu aksi berisi deeplink Anda.
`.handoffOnly(deeplink:)` mengirim hand-off dari kanal tanpa kartu. Di sandbox,
jalankan `./Scripts/run_sandbox.sh --vendor-session` untuk melihat keduanya.

## Yang perlu diperhatikan saat memakai SDK vendor

- **Sesi hidup lebih lama dari satu giliran.** Pesan bisa datang tanpa diminta
  (agen membalas sendiri). Paket meneruskannya lewat observer terpisah, jadi
  tidak akan tertukar dengan giliran yang sedang berjalan.
- **Tidak ada `completion` per request.** Giliran dianggap selesai saat
  `messageCompleted`, `failed`, atau `disconnected` dengan error. Kalau SDK
  vendor tidak punya penanda "pesan terakhir", sepakati satu dengan tim bot -
  tanpa itu, indikator mengetik tidak akan pernah berhenti.
- **Reconnect adalah keadaan normal**, bukan error. Kirim `disconnected(nil)`
  untuk penutupan yang wajar dan simpan error hanya untuk yang tidak wajar.
- **PIN dan otorisasi tidak lewat kanal vendor.** Tetap lewat
  `TanyaAIAuthorizationService` milik Anda.
