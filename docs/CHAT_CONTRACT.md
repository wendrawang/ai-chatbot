# Kontrak chat Tanya AI

Host memegang jaringan lewat `TanyaAIService`; TanyaAI hanya men-decode body JSON berikut
dan menampilkannya. Semua tanggal ISO 8601 UTC tanpa pecahan detik
(`2026-10-22T10:00:00Z`). T&C bukan bagian dari kontrak ini: host menampilkannya sebelum
membuka Tanya AI (lihat [HOST_INTEGRATION.md](HOST_INTEGRATION.md#tc-sebelum-tanya-ai)).

## Alur

```
Halaman dibuka ─► start() ─► history(before: nil) ─┬─ ada pesan ─────────────► events()  ← tetap terbuka
                                                  └─ kosong ─► config() ─────► events()
User mengirim  ─► send(text)     → tombol kirim jadi titik bergerak, draft tetap
Stream: pesan user              → pesan tampil, draft kosong, tombol jadi stop
Stream: jawaban (replyTo)       → jawaban tampil, tombol kembali kirim
User menekan stop ─► cancel(messageId) → "Jawaban dihentikan", jawaban terlambat diabaikan
Stream putus   ─► start() ─► history(before: nil) ─► events()  (sekali otomatis)
Putus lagi     ─► status "Koneksi terputus. Coba lagi"
```

- **Satu pertanyaan per waktu.** Selama menunggu pesan user atau jawaban, kirim dan shortcut
  tidak aktif.
- **Chat tampil dari stream, bukan dari `send`.** Sukses `send` hanya berarti BE menerima.
  Draft baru dikosongkan saat pesan user muncul di stream; bila diubah lebih dulu, draft dibiarkan.
- Reconnect otomatis diisi ulang setiap ada event (`message` atau `heartbeat`). History setelah
  init ulang mengisi pesan yang terlewat, termasuk jawaban yang ditunggu; pesan dengan `id` yang
  sudah tampil diabaikan.

## Pesan

```json
{
  "id": "m-123",
  "role": "user | assistant",
  "text": "Teks Markdown",
  "replyTo": "m-122",
  "createdAt": "2026-10-22T10:00:00Z"
}
```

- `replyTo` hanya untuk jawaban bot: `id` pesan user yang dijawab. Jawaban mengakhiri giliran
  bila `replyTo` sama dengan pertanyaan yang ditunggu (atau kosong).
- `text` jawaban bot berformat Markdown (render penuh menyusul di tahap tampilan).

## `start()`

Init sesi (ICT). Body: `{ "sessionId": "s-1" }`.

## `history(sessionId:before:)`

Message-histories, satu halaman, **urut dari terlama ke terbaru**:

```json
{ "messages": [ /* Pesan */ ], "hasMore": true }
```

- Saat dibuka: `before` = nil, BE mengembalikan halaman terbaru.
- Saat user menggulir mendekati atas: `before` = `id` pesan tertua yang sudah tampil.
- Ukuran halaman ditentukan BE (sandbox memakai 20). `hasMore` false menghentikan paging.

## `config(sessionId:)`

Hanya dipanggil bila halaman history pertama kosong. Gagal memuat config tidak menghalangi chat.

```json
{
  "greeting": "Halo! Ada yang bisa saya bantu?",
  "shortcuts": [
    { "id": "balance", "label": "Cek saldo", "message": "Berapa saldo saya?" },
    { "id": "transfer", "label": "Cara transfer" }
  ]
}
```

- Greeting dan shortcut tampil selama percakapan masih kosong, lalu hilang saat pesan pertama
  muncul (tidak disimpan sebagai pesan).
- Shortcut dikirim sebagai chat biasa: `message`, atau `label` bila `message` kosong.

## `events(sessionId:)` (SSE persistent)

| `event:` | `data:` | Perlakuan |
| --- | --- | --- |
| `message` | Pesan user (pantulan `send`) atau jawaban bot, satu bundle utuh | Ditambahkan ke daftar |
| `heartbeat` | Bebas, diabaikan | Penanda koneksi hidup |
| `error` | `{ "message": "..." }` | Diabaikan; BE menutup stream setelahnya |

Stream selesai atau melempar error = koneksi putus. Event lain diabaikan.

## `send(_:sessionId:)`

Kirim chat user ke ICT. Body respons tidak dibaca. Bila melempar error, giliran batal, draft tetap,
dan muncul "Pesan gagal terkirim. Silakan coba lagi."

## `cancel(messageId:sessionId:)`

Hentikan jawaban untuk pesan user `messageId` (id dari stream). Bila sukses, pertanyaan ditandai
"Jawaban dihentikan" dan jawaban yang datang sesudahnya diabaikan; jawaban yang sudah tiba lebih
dulu tetap tampil. Bila gagal, tetap menunggu jawaban dan muncul "Gagal menghentikan jawaban."

## Contoh dummy

[SandboxChatService](../TanyaAISandboxApp/Service/SandboxChatService.swift) meniru kontrak
ini dari [ChatDummy.json](../TanyaAISandboxApp/Resources/Fixtures/ChatDummy.json): greeting
dan shortcut, history panjang (`--long-history`), pantulan pesan user, jawaban per kata kunci
(`saldo`, `transfer`, `promo`, `markdown`), jawaban default, tunda jawaban (`--slow-reply` untuk
mencoba stop), dan interval heartbeat.
