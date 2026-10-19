# Tanya AI

Ikuti [AGENTS.md](AGENTS.md) untuk aturan token (CustomSizes, CustomTextLines,
CustomMotion, CustomColors), nilai awal, theme environment, fonts, localization dan style.
Scope: chat lengkap (welcome, daftar pesan, jawaban berblok, markup) dengan SSE + inquiry
per intent lewat `TanyaAIService` milik host. Minimum iOS 15 (host ikut naik ke iOS 15).

- Ukuran dan area tap 1:1 Figma lewat `.scaledToArtwork`. Jangan menambahkan
  minimum touch target 44 atau hit frame tambahan; ini keputusan UI/UX.
- Semua font Fira Sans; Open Sans menunggu revamp.
- Kontrak SSE/blok/markup: [docs/CHAT_CONTRACT.md](docs/CHAT_CONTRACT.md).
  Status ukuran Figma: [docs/FIGMA_SIZES.md](docs/FIGMA_SIZES.md).
- Keputusan arsitektur dan saran tahap berikutnya: [docs/REVAMP_NOTES.md](docs/REVAMP_NOTES.md).

Integrasi host: [docs/HOST_INTEGRATION.md](docs/HOST_INTEGRATION.md).
