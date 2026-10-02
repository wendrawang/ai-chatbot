# Validasi perubahan DesignKit — 2 Oktober 2026

Perubahan ini tidak mengubah `Tokens/Generated`. Baseline artwork default 375×812
mengikuti foto kode; 374×812 dapat dipilih melalui parameter root.

## Pemeriksaan yang selesai

- SwiftLint strict: lulus tanpa violation.
- SwiftParser check: semua method maksimal 50 baris fisik; file maksimal 250 baris.
- Build aplikasi sandbox untuk iOS Simulator melalui `xcodebuild`: lulus.
- **56 test DesignKit dan 135 test TanyaAI** dieksekusi pada iPhone 17 Pro,
  iOS 26.5 Simulator (arm64): seluruhnya lulus, tanpa skipped test.
  Termasuk runtime UIKit/WebKit, localized copy, history injection, pelepasan
  controller/ViewModel, cancellation request, dan observer setelah dismantle.
- **36 XCTest benar-benar dijalankan pada macOS**, memakai sumber produksi murni:
  ArtworkMetrics, ChipLayout, ChartGeometry, parser markup, dan CopyCatalog. Semuanya lulus.
  Termasuk 4.000 nested markup tags, geometri tidak valid, tablet cap, custom
  reference width, pixel rounding, minimum tap target, serta normalisasi angka ekstrem.
- **7 test UI sandbox** lulus: legacy navigation, deeplink, handoff approval,
  penolakan link, seluruh contoh bubble, PIN valid, dan posisi suggestion.
  Screenshot direkam sebagai attachment hasil XCTest.
- Guard literal UI, dependency komponen, serta parity key/placeholder en/id: lulus.
- CopyCatalog: regional locale, fallback, override host, placeholder literal, dan isolasi bahasa lulus.
- `git diff --check` bersih; generated token tidak berubah.

## Lingkungan dan batas pengukuran

Verifikasi menggunakan Xcode dari `/Applications/Xcode.app` pada macOS 27.0.1.
`Scripts/verify.sh` memilih runtime terpasang berdasarkan model, karena iPhone 17
Pro tersedia di iOS 26.5 tetapi tidak pada runtime terbaru di mesin ini. Pilihan
model dapat diubah dengan `TANYA_AI_SIMULATOR`; CI dapat memberi destination lengkap
melalui `TANYA_AI_TEST_DESTINATION`.

Assertion restore percakapan kosong diperbaiki: posisi paling atas UITableView
adalah `-adjustedContentInset.top`, bukan selalu nol. Test juga memastikan row kosong.
Tidak ada perubahan perilaku scroll untuk meloloskan assertion.

Test scroll 100 pesan ditambah typing row lulus ambang yang sudah ada (best-of-three
minimal 55 FPS). Sampel run: 45,34 / 55,80 / 60,15 FPS. Ini menunjukkan variasi
simulator; tidak membuktikan sustained 60 FPS pada perangkat nyata. Test pelepasan
objek lulus, tetapi tidak membuktikan bebas leak untuk seluruh integrasi vendor.
Profiling Instruments dan perangkat nyata tetap merupakan pengukuran terpisah.

## Refactor komponen dan copy

Komponen reusable telah dipindah ke DesignKit; kontrak dan state bisnis tetap
di TanyaAI. Teks bawaan UI berada di resource en/id dan dapat dioverride dari
host. Copy disalurkan ke seluruh root presentasi dan row UIKit, serta ViewModel
error. Sample history dan default suggestion produksi dihapus. Test error
terlokalisasi dan history injection ditambah; test UIKit yang terdampak rename
diperbarui dan lulus saat dijalankan di simulator.

## Batas desain yang disengaja

- Legacy palette dari `UIFont` dipertahankan sebagai ukuran final; gunakan resep
  `DesignKitTypography` agar artwork dan Dynamic Type otomatis.
- Image loader memakai cache terbatas dan cancellation task, tanpa broker untuk
  menggabungkan miss serentak. Host memiliki URLSession/URLCache dan kebijakan logout.
- HTML static menolak resource jaringan. Font mengikuti ukuran body tetapi memakai
  system web font; native card dipakai untuk tipografi brand yang harus persis.
- Theme di API dependency chat tetap snapshot; pemilihan theme live untuk halaman
  SwiftUI memakai `.theme(themeManager)`.

Lihat [panduan migrasi](DESIGNKIT_MIGRATION.md) untuk setup host dan contoh pemakaian.
