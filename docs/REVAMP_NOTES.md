# Keputusan revamp dan tahap berikutnya

Ringkasan keputusan yang sudah diambil untuk starter ini, ditambah saran untuk
tahap yang belum dikerjakan. Dokumen lain menjelaskan cara memakai API; dokumen
ini menjelaskan alasannya.

## Keputusan yang berlaku

| Topik | Keputusan | Alasan |
| --- | --- | --- |
| Minimum OS | iOS 15 untuk package, sandbox dan host | Host ikut naik ke iOS 15 pada journey revamp. |
| R.swift | `from: "7.8.0"` | Asset/locale akan bertambah; versi longgar mencegah konflik bila host juga memakai R.swift 7.x. |
| Ukuran | 1:1 Figma lewat `.scaledToArtwork` | Termasuk area tap 24pt; tidak ada minimum 44. Keputusan UI/UX. |
| Theme | `@Environment(\.designColors)`; host mengisi `tanyaAI.colors` | Tanpa singleton; `.defaultDesignColors()` untuk area bebas theme. |
| Bahasa | Host mengisi `tanyaAI.locale` dari Localize_Swift | Host tidak memakai SwiftUI locale; satu property, berlaku juga saat fitur terbuka. |
| Nilai awal | `.zero`, `String()`, `[]` | Tidak ada literal tersebar dan tidak ada enum alias. |
| Token custom | Dipisah per jenis: `CustomSizes`, `CustomTextLines` (`CustomMotion` saat ada animasi) | Aturan scaling jelas per file dan dijaga script; satu tempat untuk mengubah nilai per peran. |
| Draft | `ComposerSection` memiliki `@State` | Ketikan tidak me-render ulang header/daftar pesan. |
| Navigasi | Push ke `RevampNavigationController` milik host | Semua animasi dan swipe-back bawaan UIKit; jalur bersih terpisah dari navigasi legacy; blocker host tetap tampil di atasnya; logout melepas jalur. |

## Daftar pesan untuk ratusan chat (sudah diterapkan)

Chat memakai `ScreenHeader` mandiri dan `MessageListController` (`UITableView`):

- Cell di-recycle; isi cell `UIHostingConfiguration` (iOS 16+) atau hosting controller
  (iOS 15). `LazyVStack` tidak me-recycle dan anchor bawahnya baru ada di iOS 17.
- Pesan value type (`ChatMessage`) dengan ID stabil; snapshot diffable hanya
  `reconfigureItems` untuk baris yang berubah, jadi streaming hanya me-render baris
  jawaban terakhir.
- Pertanyaan baru ditahan dekat atas dengan preview 48 jawaban sebelumnya; ruang kosong
  sementara di bawah mengecil saat jawaban memanjang; panah kembali ke pesan terbaru.

Tahap berikutnya:
1. History dimuat per halaman (mis. 30–50 pesan) saat mendekati atas, setelah kontrak
   history ada.
2. Ukur dengan Instruments di device nyata memakai fixture 500 pesan. Hasil simulator
   bukan FPS produksi.

## Skala artwork, `UIScreen.main`, dan iPhone lipat

`UIScreen.main` deprecated sejak iOS 16. Warning baru muncul saat minimum target
dinaikkan ke 16, jadi starter iOS 15 belum terdampak. Masalah utamanya bukan
deprecation, melainkan sumber lebarnya:

- Rumus tanpa cap membuat semua ukuran membesar bila lebar bertambah. Pada layar
  lipat yang terbuka (jauh di atas 375pt), font 14 bisa menjadi lebih dari 20.
- Lebar dapat berubah saat aplikasi berjalan (lipat/buka, multitasking), sementara
  nilai statis hanya terbaca ulang saat `body` kebetulan dievaluasi.

Saran bertahap:

1. **Sekarang (iPhone, portrait):** pertahankan rumus. Tidak perlu perubahan.
2. **Sebelum mendukung perangkat lipat/iPad:** sepakati dengan UI/UX batas lebar
   referensi (cap) atau pindah ke layout adaptif untuk size class regular, misalnya
   skala 1.0 dengan lebar konten maksimum.
3. **Implementasi:** ambil lebar dari container fitur, bukan layar. Hosting controller
   fitur sudah dimiliki `TanyaAIHost`; ia dapat mengukur lebar view-nya dan
   menyuntikkannya lewat environment agar SwiftUI render ulang saat lebar berubah.
   Ini mengubah aturan "tanpa artwork environment" yang berlaku sekarang, jadi
   putuskan bersama tim ketika target perangkat lipat sudah pasti.

## Seam backend (sudah diterapkan)

Host mengimplementasikan `TanyaAIService` (SSE chat + inquiry BE per intent); TanyaAI
men-decode event dan memetakan hasil BE per intent. Kontrak lengkap:
[CHAT_CONTRACT.md](CHAT_CONTRACT.md).

- Kontrak BE berubah → ubah `Service/<Intent>Mapping.swift` saja.
- Intent baru → satu file mapping, nama di `IntentName`, daftar di `IntentMappings`.
- Implementasi dummy ada di Sandbox (fixture JSON), bukan di package produksi.
- Jangan memindahkan DependencyContainer, Coordinator, atau file alias dari `main`
  sebelum ada kebutuhan nyata.

## Persiapan Swift 6

Package masih memakai `swift-tools-version: 5.7`. Build dengan
`SWIFT_STRICT_CONCURRENCY=complete` saat ini hanya menyisakan warning pada kode lama:
`FontLoader.registered` (`static var` mutable yang dijaga `NSLock`) dan
`ArtworkScale.currentRatio` (membaca `UIScreen.main`). `TanyaAIService` sudah `Sendable`.
