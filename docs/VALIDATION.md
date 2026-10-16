# Validasi starter — 16 Oktober 2026

`Scripts/verify.sh` lulus pada simulator iPhone SE 375×667, iOS 26.5.

| Pemeriksaan | Hasil |
| --- | --- |
| DesignKit: registrasi tujuh font/glyph, hex, sizing, editor dan layout | 8 tes lulus |
| TanyaAI: locale, optional anchor/identity, pergantian host, animator | 7 tes lulus |
| Hosted unit: presentasi, lifecycle, caret kosong/fokus sesudah hapus pada tujuh font | 5 tes lulus |
| UI: tiga bahasa, satu/empat baris, inset, tepi tap, caret kosong, whitespace, callback, font fixed, tutup/buka | 8 tes lulus |
| Build generic iOS Simulator, deployment minimum iOS 15 | Lulus |
| SwiftLint/formatter, batas file/method, token/copy guard | Lulus |
| Link dokumentasi dan generated token diff | Lulus; nilai token tidak berubah, header Wendra ditambahkan |

Total **28 tes unik**. Unit layout mencakup lebar 320/375/430 dengan normal dan
accessibility XXXL (font composer tetap). Sizing diuji sampai 1024 point tanpa cap.
Ini bukan pengujian UI iPad, runtime iOS 15/device atau pengukuran rendered FPS.

Pengujian presentasi memakai `TanyaAISandboxTests` dengan sandbox app sebagai
test host dan UIWindowScene aktif. SwiftPM unit tests hanya menangani layout
anchor/identity dan algoritma animator; logic test tanpa app tidak mempunyai
scene aktif untuk menyelesaikan transisi fullscreen. Target hosted test memakai
minimum iOS 17 sesuai XCTest toolchain; minimum app/package tetap iOS 15.

## Pemeriksaan visual

Kesembilan screenshot native berikut diekspor dari hasil UI test dan diperiksa.
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

Action tetap terlihat dan berada di atas keyboard. Teks panjang scroll di dalam
editor setelah empat baris. UI test memeriksa pusat field/tombol sejajar saat
kosong/satu baris dan posisi tombol tetap saat teks bertambah menjadi empat
baris atau lebih, pada pengaturan teks normal dan accessibility XXXL. Setelah kirim,
input menyusut dan kembali sejajar tengah. Ketujuh font Fira Sans/Open Sans terdaftar dengan
PostScript name yang dibaca dari file aslinya. Registrasi dua kali diuji aman;
Chinese memakai fallback glyph native pada setiap face, diuji tanpa glyph 0.
SF Symbol send masih dummy TODO. Verifikasi font brand final tetap mengikuti aset
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

Regresi caret direproduksi pada ketujuh font: sebelum perbaikan, titik tengah
caret kosong berada 0,25–0,5 point di atas pusat bounds editor pada ukuran 14.
Tes hosted gagal sebelum perbaikan dan lulus setelah caret kosong dipusatkan ke
bounds aktual, termasuk setelah mengetik lalu menghapus draft. Bentuk/ukuran
caret native dipertahankan; saat ada teks, geometri caret tetap milik UIKit.

Screenshot sekarang diambil setelah membuka feature melalui `.tanyaAIHost(host)`
dan `host.present()`. Header native sementara menyediakan judul dan tombol kembali;
detail header Figma akan dimigrasikan terpisah. UI test memastikan tombol kembali
menutup feature dan presentasi berikutnya memulai draft kosong.
