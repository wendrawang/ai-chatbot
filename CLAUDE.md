# Minimal starting point

Ikuti [AGENTS.md](AGENTS.md) untuk aturan token (CustomSizes, CustomTextLines,
CustomColors), nilai awal, theme environment, fonts, localization dan style. Scope aktif:
shared header, composer maksimal empat baris, halaman sambutan (welcome) dari BE, dan
bridge host; tanpa session/stream. Minimum iOS 15 (host ikut naik ke iOS 15 untuk revamp).

- Ukuran dan area tap 1:1 Figma lewat `.scaledToArtwork`. Jangan menambahkan
  minimum touch target 44 atau hit frame tambahan; ini keputusan UI/UX.
- Tanpa R.swift/build tool plugin (CI host tidak bisa trust plugin). Copy lewat `ChatCopy`/`SandboxCopy`,
  ikon lewat `DesignIcon`; tambah case setiap menambah key/imageset, tes menjaga kecocokannya.
- Welcome: host men-decode objek `data` inquiry init ke `WelcomeContent` dan mengisi
  `TanyaAIHost(welcome:)`. Sapaan, judul/deskripsi/ikon kartu dari BE; emblem, latar, judul
  daftar dan chevron dari FE. Ketuk kartu = `onSend(prompt)`.
- `isAwaitingReply` dipegang host sejak chat diterima sampai jawaban datang: tombol kirim
  jadi `LoadingDots`, kartu nonaktif. Gambar URL lewat `RemoteImage` (cache memori bersama).
- Ukuran welcome/kartu/titik masih estimasi screenshot (TODO di `CustomSizes`/`CustomMotion`);
  aset `chatBackground`/`welcomeOrb` placeholder (`ChatImage`), ganti file, nama tetap.
- Folder TanyaAI: `Bridging/` (API host), `Features/<Fitur>/Models|Views`, `Shared/Keys|Extensions`,
  `Resources/`. Tests mencerminkan Sources. Detail di AGENTS.md.
- Unit test memakai Swift Testing (`@Test`, `#expect`, `#require`); UI test tetap
  XCTest. Suite yang memakai window di sandbox masuk `HostWindowTests` (berurutan).
- Keputusan arsitektur dan saran tahap berikutnya: [docs/REVAMP_NOTES.md](docs/REVAMP_NOTES.md).

Panduan implementasi dan urutan belajar: [docs/STARTING_POINT.md](docs/STARTING_POINT.md).
