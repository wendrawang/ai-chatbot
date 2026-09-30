# Audit performance dan lifecycle

Audit mencakup source package DesignKit/TanyaAI, sandbox, tests, dan contoh adapter.
Pemeriksaan otomatis menyapu seluruh source Swift non-generated; review lifecycle
berfokus pada request, callback, observer, tabel, gambar, WebView, dan rendering.

## Perbaikan

- Transcript aktif dan restore sama-sama dibatasi 100 pesan. Pesan tertua beserta
  mapping redirect dan subscription yang sudah tidak dipakai dilepas. Ini batas
  jumlah bubble, bukan batas byte konten atau penghapusan riwayat di backend.
- Download gambar mengikuti task SwiftUI, dibatalkan saat view hilang/URL berubah.
  Download memakai file sementara; ImageIO membuat thumbnail maksimal 1024 piksel
  sebelum gambar masuk cache. Cache maksimal 40 item dengan cost limit 32 MiB
  (NSCache dapat mengevict lebih awal; bukan jaminan batas RAM proses).
- Perubahan tinggi beberapa row digabung menjadi satu update main-loop. Komparasi
  row tidak lagi membuat array identifier sementara. Perubahan isi suggestion,
  penggantian objek dengan identifier sama, dan perubahan theme memicu refresh.
- Subscription memakai identitas objek; penggantian model dengan identifier sama
  tidak meninggalkan subscription pada model lama. Identitas view di sel reuse
  direset ketika message berubah.
- Callback request yang sudah dibatalkan/selesai tidak dapat menyelesaikan request
  berikutnya. Request yang selesai sinkron tidak disimpan kembali. Callback async
  tidak mempertahankan view model secara kuat.
- Observer terpasang sebelum session connect sehingga history sinkron tidak hilang.
  WebView menghentikan loading dan membersihkan delegate/KVO saat dilepas.
- Pencarian penutup tag markup dibatasi panjang tag yang valid, menghindari scan
  berulang seluruh suffix pada banyak karakter `[` biasa. Total chart dihitung
  sekali per render, bukan sekali untuk setiap segmen.

## Hasil pengujian

Lingkungan: iPhone 17 Pro simulator, iOS 26.5, Xcode di macOS arm64.

- Build aplikasi dan gate `./Scripts/verify.sh` lulus; total 159 test tanpa kegagalan.
- UI/integrasi: 7 test lulus (bubble, screenshot, navigasi, PIN, dan hand-off).
- DesignKit: 41 test lulus, termasuk registrasi tujuh font, registrasi berulang,
  Dynamic Type, tema/default override, thumbnail, markup, dan WebView.
- TanyaAI: 111 test lulus. Termasuk 25 siklus render/lepas layar, pelepasan graph
  fitur, pembatalan request, stale callback, synchronous completion/history,
  batas transcript, pelepasan row lama, dan batching 1000 token.
- Scroll fixture menerima 120 pesan dan mempertahankan 100 + row typing.
  Sampel FPS: 58.57, 60.09, 59.84. Gate existing menggunakan sampel terbaik dengan
  ambang 55 FPS; angka ini bukan benchmark perangkat fisik atau seluruh payload.
- Microbenchmark markup (macOS, build `-O`, 3 parsing string berisi 2000
  `[ordinary `): sebelum 1.064 detik, sesudah 0.0056 detik, dengan output
  identik. Ini fixture malformed-bracket sintetis, bukan percepatan seluruh UI.
- SwiftLint: 0 pelanggaran pada 187 file. Pemeriksaan method fisik juga lulus.
  Guard diuji dengan method 50 baris (diterima) dan 51 baris (ditolak).

## Kontrak dan migrasi

Nama variable 3–35 karakter; boolean berawalan `is`. File kode maksimal 250 baris,
method maksimal 50 baris fisik. Kontrak generated dikecualikan, tanpa rename atau
format otomatis. Nama `transitionWasCancelled` pada test double tetap mengikuti
protocol UIKit dengan pengecualian lokal yang dijelaskan.

API source berubah untuk mengikuti aturan nama:

- Model yang sebelumnya memakai `id` kini memakai `identifier`. Gunakan
  `ForEach(items, id: \.identifier)`; conformance `Identifiable` dihapus dari
  model terkait agar tidak menyisakan property dua karakter.
- `allowsMultipleSelection` menjadi `isMultipleSelectionAllowed` di Swift.
  Key JSON tetap `allowsMultipleSelection`, sehingga payload server tidak berubah.
- Flag publik `showsShortcuts`, `showsSuggestions`, `showsTypingRow`, dan
  `canSubmit` menjadi `isShortcutRowVisible`, `isSuggestionRowVisible`,
  `isTypingRowVisible`, dan `isSubmittable`.
- Argument `authorizesInFeature` menjadi `isAuthorizationEnabled`.

## Batas verifikasi

Test pelepasan reference mendeteksi siklus pada skenario yang dijalankan, tetapi
bukan bukti bahwa seluruh jalur aplikasi atau SDK vendor bebas memory leak.
Contoh Sendbird/3Dolphins diperiksa dan dilint; SDK vendor tidak tersedia di target
test. Profiling Instruments pada perangkat fisik dengan payload produksi tetap
perlu untuk mengukur peak memory, hitch, dan lifecycle SDK sebenarnya.

Batas transcript tidak membatasi ukuran satu payload. HTML menggunakan proses
WebKit dan gambar eksternal masih mengikuti aturan jaringan yang didokumentasikan
pada PR. Theme UIKit berupa snapshot; modifier SwiftUI mengikuti manager secara
live. Palette Premier/Private masih dummy sesuai instruksi.
