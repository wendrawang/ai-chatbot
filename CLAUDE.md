# Minimal starting point

Ikuti [AGENTS.md](AGENTS.md) untuk aturan token (CustomSizes, CustomTextLines,
CustomColors), nilai awal, theme environment, fonts, localization dan style. Scope aktif:
screen kosong, shared header, composer maksimal empat baris, dan bridge host;
tanpa session/backend. Minimum iOS 15 (host ikut naik ke iOS 15 untuk revamp).

- Ukuran dan area tap 1:1 Figma lewat `.scaledToArtwork`. Jangan menambahkan
  minimum touch target 44 atau hit frame tambahan; ini keputusan UI/UX.
- Flow chat: init → history → config (bila kosong) → SSE; chat tampil dari stream, tombol kirim
  → titik bergerak → stop (cancel). T&C ditampilkan host sebelum Tanya AI. Kontrak:
  [docs/CHAT_CONTRACT.md](docs/CHAT_CONTRACT.md).
- Unit test memakai Swift Testing (`@Test`, `#expect`, `#require`); UI test tetap
  XCTest. Suite yang memakai window di sandbox masuk `HostWindowTests` (berurutan).
- Keputusan arsitektur dan saran tahap berikutnya: [docs/REVAMP_NOTES.md](docs/REVAMP_NOTES.md).

Panduan implementasi dan urutan belajar: [docs/STARTING_POINT.md](docs/STARTING_POINT.md).
