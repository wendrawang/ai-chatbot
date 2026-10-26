# Kontrak chat Tanya AI

Host memegang jaringan lewat `TanyaAIService`; TanyaAI hanya men-decode body JSON berikut
dan menampilkannya. Semua tanggal ISO 8601 UTC tanpa pecahan detik
(`2026-10-22T10:00:00Z`).

## Alur

```
Halaman dibuka ─► start() ─► history(before: nil) ─► events()  ← tetap terbuka
User mengirim  ─► send(text)  (stream tetap terbuka; jawaban datang lewat events)
Stream putus   ─► start() ─► history(before: nil) ─► events()  (sekali otomatis)
Putus lagi     ─► status "Koneksi terputus. Coba lagi"
```

Reconnect otomatis diisi ulang setiap ada event (`message` atau `heartbeat`), jadi
koneksi yang sempat sehat boleh putus dan pulih berkali-kali. History setelah init ulang
mengisi pesan yang terlewat; pesan dengan `id` yang sudah tampil diabaikan.

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

- `replyTo` hanya untuk jawaban bot: `id` chat user yang dijawab. Penanda
  "sedang menjawab" hilang begitu jawaban dengan `replyTo` itu tiba.
- `text` jawaban bot berformat Markdown (render penuh menyusul di tahap tampilan).

## `start()`

Init sesi. Body: `{ "sessionId": "s-1" }`.

## `history(sessionId:before:)`

Satu halaman, **urut dari terlama ke terbaru**:

```json
{ "messages": [ /* Pesan */ ], "hasMore": true }
```

- Saat dibuka: `before` = nil, BE mengembalikan halaman terbaru.
- Saat user menggulir mendekati atas: `before` = `id` pesan tertua yang sudah tampil;
  BE mengembalikan pesan yang lebih lama dari itu.
- Ukuran halaman ditentukan BE (sandbox memakai 20). `hasMore` false menghentikan paging.

## `events(sessionId:)` (SSE persistent)

| `event:` | `data:` | Perlakuan |
| --- | --- | --- |
| `message` | Pesan (biasanya jawaban bot, satu bundle utuh) | Ditambahkan ke daftar |
| `heartbeat` | Bebas, diabaikan | Penanda koneksi hidup |
| `error` | `{ "message": "..." }` | Diabaikan; BE menutup stream setelahnya |

Stream selesai atau melempar error = koneksi putus. Event lain diabaikan.

## `send(_:sessionId:)`

Kirim chat user. Body: Pesan user yang sudah tersimpan (dengan `id` dari BE). Chat langsung
tampil di daftar sebelum respons; bila request gagal, chat ditandai "Gagal terkirim. Ketuk untuk
coba lagi."

## Contoh dummy

[SandboxChatService](../TanyaAISandboxApp/Service/SandboxChatService.swift) meniru kontrak
ini dari [ChatDummy.json](../TanyaAISandboxApp/Resources/Fixtures/ChatDummy.json): history
awal, jawaban per kata kunci (`saldo`, `transfer`, `promo`, `markdown`), jawaban default,
tunda jawaban, dan interval heartbeat.
