# Validasi perubahan DesignKit — 2 Oktober 2026

Perubahan ini tidak mengubah `Tokens/Generated`. Baseline artwork default 375×812
mengikuti foto kode; 374×812 dapat dipilih melalui parameter root.

## Pemeriksaan yang selesai

- SwiftLint strict: lulus tanpa violation.
- SwiftParser check: semua method maksimal 50 baris fisik; file maksimal 250 baris.
- Compiler iOS 15 simulator: module emission DesignKit, enam target TanyaAI,
  dan sumber aplikasi sandbox lulus. Karena SwiftPM/Xcode tidak dapat menulis cache
  sistem di sesi ini, pemeriksaan memakai `swiftc` dengan module cache lokal dan
  accessor `Bundle.module` sementara; ini bukan hasil build aplikasi lengkap.
- Semua sumber test DesignKit dan lima target test TanyaAI lolos type checking
  terhadap modul di atas. Kedua manifest Package.swift juga lolos type checking.
- **36 XCTest benar-benar dijalankan pada macOS**, memakai sumber produksi murni:
  ArtworkMetrics, ChipLayout, ChartGeometry, parser markup, dan CopyCatalog. Semuanya lulus.
  Termasuk 4.000 nested markup tags, geometri tidak valid, tablet cap, custom
  reference width, pixel rounding, minimum tap target, serta normalisasi angka ekstrem.
- Guard literal UI, dependency komponen, serta parity key/placeholder en/id: lulus.
- CopyCatalog: regional locale, fallback, override host, placeholder literal, dan isolasi bahasa lulus.
- `git diff --check` bersih; generated token tidak berubah.

## Yang belum dapat dijalankan dalam sesi ini

Full `xcodebuild`/simulator terhalang CoreSimulatorService dan izin cache SwiftPM.
Test runtime UIKit/WebKit, screenshot, dan Instruments Leaks/Allocations belum
terverifikasi. Test lifecycle WebKit telah ditambahkan dan lolos type checking,
tetapi belum dieksekusi di iOS. Jalankan `Scripts/verify.sh` dan profiling pada host
sebelum migrasi produksi luas. Tidak ada klaim bebas leak atau jaminan FPS perangkat.

## Refactor komponen dan copy

Komponen reusable telah dipindah ke DesignKit; kontrak dan state bisnis tetap
di TanyaAI. Teks bawaan UI berada di resource en/id dan dapat dioverride dari
host. Copy disalurkan ke seluruh root presentasi dan row UIKit, serta ViewModel
error. Sample history dan default suggestion produksi dihapus. Test error
terlokalisasi dan history injection ditambah; test UIKit yang terdampak rename
diperbarui dan lolos type checking, belum dieksekusi.

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
