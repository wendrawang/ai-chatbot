# Validasi perubahan DesignKit — 2 Oktober 2026

Perubahan ini tidak mengubah `Tokens/Generated`. Baseline artwork default 375×812
mengikuti foto kode; 374×812 dapat dipilih melalui parameter root.

## Pemeriksaan yang selesai

- SwiftLint strict: lulus tanpa violation.
- SwiftParser check: semua method maksimal 50 baris fisik; file maksimal 250 baris.
- Build aplikasi sandbox untuk iOS Simulator melalui `xcodebuild`: lulus.
- **56 test DesignKit dan 148 test TanyaAI** dieksekusi pada iPhone 17 Pro,
  iOS 26.5 Simulator (arm64): seluruhnya lulus, tanpa skipped test.
  Termasuk runtime UIKit/WebKit, localized copy, history injection, pelepasan
  controller/ViewModel, cancellation request, dan observer setelah dismantle.
- **36 XCTest benar-benar dijalankan pada macOS**, memakai sumber produksi murni:
  ArtworkMetrics, ChipLayout, ChartGeometry, parser markup, dan CopyCatalog. Semuanya lulus.
  Termasuk 4.000 nested markup tags, geometri tidak valid, tablet cap, custom
  reference width, pixel rounding, minimum tap target, serta normalisasi angka ekstrem.
- **8 test UI sandbox** lulus: legacy navigation, deeplink, handoff approval,
  penolakan link, seluruh contoh bubble, PIN valid, posisi suggestion, dan radio
  yang menjadi prompt lalu hilang dari jawaban.
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
minimal 55 FPS). Sampel run terbaru: 58,72 / 56,95 / 59,90 FPS.
Run sebelumnya: 45,34 / 55,80 / 60,15 FPS. Ini menunjukkan variasi
simulator; tidak membuktikan sustained 60 FPS pada perangkat nyata. Test pelepasan
objek lulus, tetapi tidak membuktikan bebas leak untuk seluruh integrasi vendor.
Percobaan Instruments Leaks gagal attach dengan `Cannot find process for provided pid`
meskipun app berjalan; tidak ada hasil scan Leaks yang diklaim. Profiling perangkat
nyata/vendor SDK tetap merupakan pengukuran terpisah.

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

## Jawaban empat bagian — perubahan setelah PR input empat baris

Input generik tetap `DesignKit.MessageComposer`. Jawaban text tanpa outline,
radio per option, gambar, dan action dikomposisikan oleh `ResponseContent`;
aturan kirim dan consumed state berada di fitur. Tambahan test mencakup 15
kombinasi decode, prompt fallback, duplicate/replay, preserved content saat
streaming, restored answered state, dan pengecilan row tanpa overlap.

Test UI khusus radio lulus dan merekam screenshot
[sebelum](../Artifacts/Screenshots/answer-before-selection.png) /
[sesudah](../Artifacts/Screenshots/answer-after-selection.png). Panduan JSON dan
host tersedia di [ANSWER_CONTENT.md](ANSWER_CONTENT.md).

## Kontrak Tencent dan kontrol percakapan — 3 Oktober 2026

- **56 test DesignKit dan 164 test TanyaAI** lulus pada iPhone 17 Pro / iOS 26.5
  Simulator, tanpa skipped test. Termasuk seluruh 15 kombinasi elemen custom,
  Unicode, destination type, malformed payload, reference/raw amount konfirmasi,
  history/live parity, radio lama/replay, dan pelepasan scroll coordinator/control.
- **9 test UI unik** telah lulus dalam run lengkap dan rerun yang terdampak. Run
  lengkap pertama menemukan masalah command scroll yang belum diamati bridge
  UIKit dan test PIN yang hanya menggulir sampai judul. Bridge kini mengamati
  control, visibility tidak muncul selama auto-follow, dan test PIN memastikan
  tombolnya terlihat. Ketiga test terkait lulus pada rerun.
- Input kosong, 1 baris, 4 baris, dan >4 baris direkam lewat XCTest dan diperiksa
  visualnya. Tinggi berhenti tumbuh pada 4 baris; UITextView kemudian scroll.
- Semua file Swift contoh Tencent lolos **typecheck dengan framework asli
  ImSDK_Plus_Swift 9.1.7818** dari podspec, target iOS 15 arm64 Simulator. Ini
  memverifikasi API SDK dan package; login, server, serta delivery pada real
  device tetap membutuhkan host. Tidak ada SDK binary/kredensial yang di-commit.
- Script REST diuji secara offline: fixture request dan jalur success/FAIL
  Tencent benar. Tidak ada pesan yang dikirim ke akun nyata selama verifikasi.
- Style/literal UI/localization guard dan `git diff --check` lulus. Generated
  token tidak berubah. Duplicate suppression FIFO dibatasi 512 ID dan antrean
  live selama history dibatasi 100 pesan; message graph package tetap 100.

Bukti visual: [arrow muncul](../Artifacts/Screenshots/scroll-to-latest-visible.png),
[sesudah kembali ke latest](../Artifacts/Screenshots/scroll-to-latest-completed.png),
[input kosong](../Artifacts/Screenshots/composer-empty.png),
[1 baris](../Artifacts/Screenshots/composer-1-line.png),
[4 baris](../Artifacts/Screenshots/composer-4-lines.png), dan
[lebih dari 4 baris](../Artifacts/Screenshots/composer-over-4-lines.png).
Tidak ada klaim baru tentang hasil Instruments Leaks atau sustained FPS perangkat nyata.
