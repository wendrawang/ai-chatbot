# Minimal starting point

Ikuti [AGENTS.md](AGENTS.md) untuk aturan token (CustomSizes, CustomTextLines,
CustomColors), nilai awal, theme environment, fonts, localization dan style. Scope aktif:
screen kosong, shared header, composer maksimal empat baris, dan bridge host;
tanpa session/backend. Minimum iOS 15 (host ikut naik ke iOS 15 untuk revamp).

- Ukuran dan area tap 1:1 Figma lewat `.scaledToArtwork`. Jangan menambahkan
  minimum touch target 44 atau hit frame tambahan; ini keputusan UI/UX.
- Tanpa R.swift/build tool plugin (CI host tidak bisa trust plugin). Copy lewat `ChatCopy`/`SandboxCopy`,
  ikon lewat `DesignIcon`; tambah case setiap menambah key/imageset, tes menjaga kecocokannya.
- Unit test memakai Swift Testing (`@Test`, `#expect`, `#require`); UI test tetap
  XCTest. Suite yang memakai window di sandbox masuk `HostWindowTests` (berurutan).
- Keputusan arsitektur dan saran tahap berikutnya: [docs/REVAMP_NOTES.md](docs/REVAMP_NOTES.md).

Panduan implementasi dan urutan belajar: [docs/STARTING_POINT.md](docs/STARTING_POINT.md).
