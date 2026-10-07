# Validasi perubahan DesignKit — 2–5 Oktober 2026

Perubahan ini tidak mengubah `Tokens/Generated`. Catatan 2–3 Oktober di bawah
merekam implementasi container/environment sebelumnya. Pada 4 Oktober, sesuai
preferensi host, ukuran diubah menjadi properti `.sizeInArtwork` berbasis layar
dengan reference hardcoded 375×812 setelah koreksi typo dari host. Setup root artwork telah dihapus.

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

## Properti ukuran langsung — 4 Oktober 2026

- Artwork environment dan seluruh modifier root artwork dihapus. Komponen memakai
  `value.sizeInArtwork`, `value.strokeInArtwork`, dan `value.tapTargetInArtwork`.
- Reference hardcoded **374×812** berada di adapter handwritten, di luar generated
  token. Lebar layar dibaca saat properti dipakai; pembulatan mengikuti point pada
  extension existing, dengan cap 1.25, stroke minimum satu piksel, dan target tap 44pt.
- **58 test DesignKit dan 164 test TanyaAI** lulus pada iPhone 17 Pro / iOS 26.5
  Simulator, tanpa skipped test. Test mencakup properti tanpa setup root, ukuran
  tidak valid, batas skala, minimum target, dan font yang tidak terskalakan dua kali.
- **9 test UI** lulus dalam satu run lengkap tanpa skipped test: navigasi/deeplink,
  radio menjadi prompt, arrow kembali ke latest, seluruh contoh kartu, PIN, dan
  suggestion yang tidak menutupi jawaban.
- Build sandbox dan strict style/literal/localization checks lulus. Tidak ada
  perubahan generated token, kontrak SDK, atau observer/global state baru.
- Screenshot input kosong, 1, 4, dan lebih dari 4 baris diperbarui dari XCTest
  setelah perubahan ukuran dan diperiksa visualnya.

Pemeriksaan screenshot juga menemukan feedback tinggi viewport WebKit saat fitting
row. Observasi kini mengabaikan tinggi yang sama dengan viewport sementara, sehingga
card tidak membesar mengikuti ukuran fitting. Regression test ditambah, seluruh 58
test DesignKit lulus, dan test UI arrow diulang setelah fix serta lulus. Screenshot
arrow diperbarui dari rerun; sembilan test UI unik tetap semuanya telah lulus.

Reference awal 374×812 pada run 4 Oktober di atas mengikuti input yang kemudian
dikoreksi host menjadi **375×812**. Implementasi dan panduan host sekarang memakai
375×812; properti `.sizeInArtwork` tetap tanpa environment atau setup root.
Seluruh 58 test DesignKit dijalankan ulang setelah koreksi dan lulus tanpa skipped
test. Strict style/literal/localization checks juga lulus; generated token tetap utuh.

## Host optional dan setup AppState — 5 Oktober 2026

- `.tanyaAIHost` menerima `TanyaAIHost?` langsung; overload non-optional tetap
  tersedia. Nil hanya menghapus anchor presentasi, tanpa mengganti konten Main.
- **166 test TanyaAI** lulus dalam satu run lengkap pada iPhone 17 Pro / iOS 26.5
  Simulator, tanpa skipped test. Test tambahan memeriksa anchor dibuat/dilepas
  pada `nil → host → nil`, instance field dan input Main tetap bertahan, serta
  controller dan host non-optional dilepas setelah teardown.
- Build sandbox, strict lint, batas file/method, literal/dependency/localization
  checks, dan `git diff --check` lulus. Generated token tidak berubah.
- Panduan Tencent memakai modifier langsung di Main. AppState menyiapkan host
  sebelum `.loggedIn`, login Tencent sekali per sesi, dan reset readiness/error
  serta logout SDK setelah chat ditutup. Router deeplink tetap berada di Main.


### 5 Oktober: composer lebih sederhana dan token spacing langsung

Composer memisahkan margin luar, isi input, dan dekorasi permukaan; send/stop memakai
satu tombol. Padding horizontal luar/dalam memakai FigmaSize 16, lingkaran tombol 24,
radius 8, background putih dengan stroke dan shadow. Spacing generated dipakai langsung
di komponen; nilai token dan rumus artwork tidak berubah.

Validasi: 58 test DesignKit lulus tanpa skip. Tiga test UI lulus untuk input 1/4/6 baris,
radio consumption, dan scroll-to-latest. Test suggestion-safe-layout gagal satu kali pada
`isHittable` teks statis, lalu lulus pada rerun tanpa perubahan kode; screenshot memperlihatkan
teks tidak tertutup. Strict lint 0 violation, guard design-system dan whitespace lulus.
Screenshot composer satu/empat/lebih dari empat baris diperbarui dari XCTest.
Tidak ada klaim benchmark performa atau Instruments baru untuk perubahan ini.


### 7 Oktober: lebar composer dan area sentuh

Test UI baru memakai 128 huruf tanpa spasi dan memeriksa lebar field tidak berubah,
field tidak melewati area tombol, serta tombol tetap berada di layar dan bisa ditekan.
Baseline package, ikon resizable, dan SVG lokal dalam asset catalog lulus tanpa priority.
Eksperimen ukuran tap 4, diameter 24, padding ikon 6, spacing token 16 mereproduksi
field/tombol keluar dari container: rumus spacing/trailing menjadi -36 sebelum scaling.
Mengubah area tap ke 44 saja membuat test lulus. Untuk gap visual 16, kompensasi area
tap di tiap sisi adalah `(tapWidth - visualWidth) / 2`; lakukan perhitungan pada ukuran
final yang sama dengan frame. Eksperimen resource/ukuran tidak disertakan dalam source.
Pemeriksaan ini dijalankan pada iPhone 17 Pro/iOS 26.5 Simulator; implementasi host
privat dan SVG aktual tidak tersedia untuk diperiksa langsung.
