# Validasi starter

## Perubahan R.swift — 17 Oktober 2026

| Pemeriksaan perubahan terbaru | Hasil |
| --- | --- |
| SwiftLint, formatter, batas file/method, token/copy guard | Lulus, tanpa pelanggaran |
| Manifest DesignKit/TanyaAI dan referensi plugin/runtime pada project | Lulus |
| Generator R.swift untuk package dan sandbox project | Lulus |
| Kompilasi modul DesignKit/TanyaAI terhadap SDK iOS Simulator, minimum iOS 15 | Lulus melalui swiftc |
| Pemeriksaan tipe test kedua package dan sandbox dengan accessor generated | Lulus |
| Resource localization fitur dan sandbox | 20 assertion lulus pada macOS |
| Kompilasi tiga PDF imageset menjadi Assets.car | Lulus melalui actool |
| Full xcodebuild dan pengujian runtime simulator | Belum berhasil dijalankan pada lingkungan saat ini |
| Diff token generated dan tujuh font | Tidak berubah |

Pemeriksaan localization menjalankan source `String+Resource.swift` dan accessor
R.swift asli terhadap bundle berisi ketiga `.lproj`. Mencakup English, Indonesia,
`zh-Hans`, pemilihan Chinese untuk `zh_CN`, dan fallback English untuk `fr_FR`.

Pemeriksaan swiftc memakai source produksi dan generated resource asli. Karena
dijalankan di luar SwiftPM, accessor `Bundle.module` sementara menunjuk `Bundle.main`
untuk pemeriksaan kompilasi saja. Ini tidak memverifikasi packaging bundle atau
eksekusi plugin dari build Xcode secara penuh. Tes `AssetTests` ditambahkan untuk
memeriksa pemuatan gambar dari bundle package saat suite iOS berikutnya dijalankan.

Lingkungan membatasi cache/proses sandbox milik Xcode dan koneksi CoreSimulator.
Kompilasi resource dan assertion macOS di atas berhasil, tetapi tidak menggantikan
suite UI/lifecycle. Jalankan `Scripts/verify.sh` pada Mac dengan simulator aktif
sebelum merge. Screenshot dan 35 tes pada bagian berikut adalah **baseline
16 Oktober**, bukan hasil pengujian ulang perubahan R.swift.

Ikon send/back/more kini berupa PDF vector dummy dalam xcassets, diakses lewat
R.swift. TODO penggantian export Figma ada pada README asset. Layout/padding,
ukuran font tetap 14, dan batas empat baris tidak diubah.

## Baseline — 16 Oktober 2026

`Scripts/verify.sh` lulus pada simulator iPhone SE 375×667, iOS 26.5.
Tiga tes UI header juga lulus saat dijalankan terpisah pada iPhone 17 Pro,
iOS 26.5 (402×874 point).

| Pemeriksaan | Hasil |
| --- | --- |
| DesignKit: registrasi tujuh font/glyph, hex, sizing, editor, header dan layout | 9 tes lulus |
| TanyaAI: locale, optional anchor/identity, pergantian host, animator | 7 tes lulus |
| Hosted unit: presentasi, lifecycle, caret, reusable container dan isolasi boundary | 8 tes lulus |
| UI: composer/caret, tiga bahasa, header, scroll, menu, keyboard dan tutup/buka | 11 tes lulus |
| Build generic iOS Simulator, deployment minimum iOS 15 | Lulus |
| SwiftLint/formatter, batas file/method, token/copy guard | Lulus |
| Link dokumentasi dan generated token diff | Lulus; generated token tidak berubah |

Total **35 tes unik**. Unit layout mencakup lebar 320/375/430 dengan normal dan
accessibility XXXL (font composer tetap). Sizing diuji sampai 1024 point tanpa cap.
Ini bukan pengujian UI iPad, runtime iOS 15/device atau pengukuran rendered FPS.

Pengujian presentasi memakai `TanyaAISandboxTests` dengan sandbox app sebagai
test host dan UIWindowScene aktif. SwiftPM unit tests hanya menangani layout
anchor/identity dan algoritma animator; logic test tanpa app tidak mempunyai
scene aktif untuk menyelesaikan transisi fullscreen. Target hosted test memakai
minimum iOS 17 sesuai XCTest toolchain; minimum app/package tetap iOS 15.

## Pemeriksaan visual

Empat belas screenshot native berikut diekspor dari hasil UI test dan diperiksa.
Gambar tidak diedit atau dibuat dengan generator gambar.

- [English](../Artifacts/Screenshots/starter-en.png)
- [Bahasa Indonesia](../Artifacts/Screenshots/starter-id.png)
- [简体中文](../Artifacts/Screenshots/starter-zh-Hans.png)
- [Satu baris dan keyboard](../Artifacts/Screenshots/starter-one-line-keyboard.png)
- [Empat baris dan keyboard](../Artifacts/Screenshots/starter-four-lines-keyboard.png)
- [Pengaturan accessibility XXXL, font composer tetap](../Artifacts/Screenshots/starter-accessibility-zh-Hans.png)
- [Kosong dan fokus](../Artifacts/Screenshots/starter-empty-focused.png)
- [Caret setelah mengetik](../Artifacts/Screenshots/starter-caret-one-line.png)
- [Kosong setelah dihapus](../Artifacts/Screenshots/starter-empty-after-clearing.png)
- [Header dan awal konten dummy](../Artifacts/Screenshots/header-demo-top.png)
- [Header setelah scroll](../Artifacts/Screenshots/header-demo-scrolled.png)
- [Kembali ke atas](../Artifacts/Screenshots/header-demo-returned.png)
- [Awal konten di iPhone 17 Pro](../Artifacts/Screenshots/header-demo-top-large.png)
- [Setelah scroll di iPhone 17 Pro](../Artifacts/Screenshots/header-demo-scrolled-large.png)

Action tetap terlihat dan berada di atas keyboard. Teks panjang scroll di dalam
editor setelah empat baris. UI test memeriksa pusat field/tombol sejajar saat
kosong/satu baris dan posisi tombol tetap saat teks bertambah menjadi empat
baris atau lebih, pada pengaturan teks normal dan accessibility XXXL. Setelah kirim,
input menyusut dan kembali sejajar tengah. Ketujuh font Fira Sans/Open Sans terdaftar dengan
PostScript name yang dibaca dari file aslinya. Registrasi dua kali diuji aman;
Chinese memakai fallback glyph native pada setiap face, diuji tanpa glyph 0.
SF Symbol send/back/more masih dummy TODO. Verifikasi font brand final tetap mengikuti aset
resmi yang nanti diberikan, termasuk keputusan font Chinese brand.

Composer dan placeholder memakai token 14 dengan leading role 21, hanya mengikuti
artwork scaling; Dynamic Type tidak mengubah font/leading composer. UI test
membandingkan ukuran field kosong, satu baris, empat baris dan composer pada
pengaturan normal dengan accessibility XXXL: semuanya tetap sama.
Pada artwork 375, tes UI memeriksa jarak 16 antara border dan lingkaran tombol kanan/bawah, field
kiri, serta field atas ketika multiline. Tap target tetap 44×44; tap dekat tepi
atas/bawah/kiri/kanannya, di luar lingkaran 24, berhasil mengirim draft. Padding
mengompensasi inset tiap sisi `(44 - 24) / 2 = 10`, sehingga padding luar area
tap adalah 6, termasuk saat pengaturan ukuran teks pengguna diperbesar.

Regresi caret direproduksi pada ketujuh font: koreksi yang hanya memusatkan caret
kosong ke bounds membuat posisinya berbeda 0,25–0,5 point dari caret saat mengetik.
Tes hosted gagal sebelum perbaikan dan lulus setelah geometri native dipakai pada
semua state. Rect caret di awal dokumen dibandingkan saat kosong, setelah mengetik
dan setelah menghapus draft: semuanya tetap sama. Hint dan input memakai font
yang sama; ZStack `.leading` memusatkan hint secara vertikal pada field.

Screenshot sekarang diambil setelah membuka feature melalui `.tanyaAIHost(host)`
dan `host.present()`. Header SwiftUI menyediakan judul, kembali dan menu titik tiga.
UI test memastikan tombol kembali
menutup feature dan presentasi berikutnya memulai draft kosong.

## Header dan scroll

Tes UI memeriksa judul di tengah, tap target back/more minimum 44, jarak awal
konten dari header, perubahan boundary ketika scroll, mencapai akhir, lalu
kembali ke state awal. Header dan composer tetap pada posisi yang sama. Header
tetap stabil dengan keyboard dan input empat baris, termasuk pada pengaturan
teks accessibility XXXL. Menu diterjemahkan dalam tiga bahasa; tanpa handler sesi,
item “Percakapan baru” disabled. Pembuatan sesi/welcome belum diimplementasikan.

Screenshot memperlihatkan separator dan surface material setelah scroll; judul
tetap tajam. Unit layout menguji judul sangat panjang pada lebar 320/375/430,
dengan dan tanpa trailing action. Fallback Reduce Transparency memakai surface
opaque; pengaturan sistem ini belum diuji melalui otomasi UI.

Tes hosted memastikan injected content dilepas setelah dismiss walaupun host
masih dimiliki caller. Tes lifecycle existing juga lulus. Ini menguji ownership
jalur present/dismiss yang tersedia, bukan audit Instruments seluruh aplikasi.
Tes presentasi juga memastikan screen fitur tidak mempunyai UINavigationController
di dalam hierarchy-nya, sementara navigation stack host tetap utuh.

## Reuse dan pembatasan update scroll

`ChatScreen` menggunakan `ScreenContainer` DesignKit. Container menyimpan satu
Boolean, memakai ID UUID lokal melalui `@State`, dan memasang header/scroll/footer otomatis.
Modifier `.onScrollBoundaryChange` juga diuji terpisah dari fitur chat pada dua
ScrollView bertingkat: menggeser inner tidak mengubah status outer, dan sebaliknya.
Offset 0,2 point di bawah toleransi tidak memicu transisi. Enam perpindahan offset
di sisi boundary yang sama hanya menghasilkan satu transisi Boolean; kembali ke
atas menghasilkan satu transisi lagi. Nilai awal dikirim sekali saat muncul.

Tes container dengan beberapa child ViewBuilder memastikan inset header dan
margin diterapkan satu kali pada keseluruhan konten, bukan berulang per child.
Callback count ini membatasi update state; GeometryReader tetap mengevaluasi
geometri saat layout scroll berubah. Tidak ada klaim hasil FPS atau profiling
Instruments berdasarkan tes callback tersebut.
