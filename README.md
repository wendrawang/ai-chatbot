# Tanya AI

Chat Tanya AI untuk di-embed di host app, iOS 15: welcome dengan shortcut, daftar
pesan untuk ratusan chat, jawaban berblok (teks bermarkup, tabel, pilihan, media,
action, suggestion), dan alur SSE + inquiry BE per intent. Copy tersedia dalam
English, Bahasa Indonesia, dan 简体中文.

```sh
./Scripts/run_sandbox.sh --language id
./Scripts/run_sandbox.sh --language en
./Scripts/run_sandbox.sh --language zh-Hans
```

Sandbox meniru host: `AppDelegate` + `SceneDelegate` dengan `RevampNavigationController`
sebagai root dan service dummy dari fixture JSON (tanpa network). Tekan “Buka Tanya AI”,
lalu:

- ketuk **Cek Portofolio** → status loading → intent `review-porto` → inquiry dummy → tabel;
- tulis pertanyaan bebas → teks bermarkup (bold, coret, warna, link web/telepon/deeplink),
  pilihan, media, action, dan suggestion;
- tombol stop selama jawaban mengalir; menu titik tiga → percakapan baru;
- kembali dengan tombol back atau swipe dari tepi kiri.

- [Kontrak SSE, blok, markup dan link](docs/CHAT_CONTRACT.md)
- [Integrasi host](docs/HOST_INTEGRATION.md)
- [Status ukuran Figma](docs/FIGMA_SIZES.md)
- [Pola view dan resource R.swift](docs/VIEW_TEMPLATE.md)
- [Aturan implementasi](AGENTS.md)
- [Keputusan revamp dan tahap berikutnya](docs/REVAMP_NOTES.md)
- [Hasil validasi](docs/VALIDATION.md)

Jalankan `Scripts/verify.sh` sebelum review.
