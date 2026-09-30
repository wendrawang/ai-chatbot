# Contoh response bubble

Setiap file memakai envelope dokumentasi `{ "event": "...", "data": { ... } }`.
Adapter meneruskan `event` sebagai nama dan hanya isi `data` ke decoder package.
Ini bukan endpoint backend atau request vendor yang dapat dikirim tanpa adapter.

- Mulai dengan `conversation.json`: satu rangkaian balasan lengkap.
- Pilih `status.json`, `image.json`, `choices.json`, dan file lain untuk satu bubble.
- `started.json`, `text.json`, `completed.json`, `heartbeat.json` menjelaskan lifecycle.
- `suggestions.json` menghasilkan saran satu-tap; `choices.json` memiliki tombol submit.
- `approval.json` berisi expiry dummy 2099. Backend harus memakai expiry challenge asli.
- `fallback.json` menunjukkan perilaku jenis content yang belum dikenal aplikasi.

Kontrak field dan mapping adapter: [BUBBLE_SCHEMA.md](../../docs/BUBBLE_SCHEMA.md).
Cara menjalankan UI dummy: [HOST_INTEGRATION.md](../../docs/HOST_INTEGRATION.md).
