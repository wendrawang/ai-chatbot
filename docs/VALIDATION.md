# Validasi starter — 15 Oktober 2026

`Scripts/verify.sh` lulus pada simulator iPhone SE 375×667, iOS 26.5.

| Pemeriksaan | Hasil |
| --- | --- |
| DesignKit: font/glyph, hex, sizing, editor dan layout | 8 tes lulus |
| TanyaAI: locale en/id/zh-Hans, zh_CN dan fallback English | 2 tes lulus |
| UI: tiga bahasa, empat baris, whitespace, callback ditolak, font terbesar | 5 tes lulus |
| Build generic iOS Simulator, deployment minimum iOS 15 | Lulus |
| SwiftLint/formatter, batas file/method, token/copy guard | Lulus |
| Link dokumentasi dan generated token diff | Lulus; generated tidak berubah |

Total **15 tes unik**. Unit layout mencakup lebar 320/375/430 dengan normal dan
accessibility XXXL. Sizing diuji sampai 1024 point tanpa cap. Ini bukan pengujian
UI iPad, runtime iOS 15/device atau pengukuran rendered FPS.

## Pemeriksaan visual

Kelima screenshot native berikut diekspor dari hasil UI test dan diperiksa.
Gambar tidak diedit atau dibuat dengan generator gambar.

- [English](../Artifacts/Screenshots/starter-en.png)
- [Bahasa Indonesia](../Artifacts/Screenshots/starter-id.png)
- [简体中文](../Artifacts/Screenshots/starter-zh-Hans.png)
- [Empat baris dan keyboard](../Artifacts/Screenshots/starter-four-lines-keyboard.png)
- [Accessibility XXXL](../Artifacts/Screenshots/starter-accessibility-zh-Hans.png)

Action tetap terlihat dan berada di atas keyboard. Teks panjang scroll di dalam
editor setelah empat baris. Font Open Sans terdaftar dengan PostScript name yang
benar; Chinese memakai fallback glyph native, diuji tidak menghasilkan glyph 0.
SF Symbol send masih dummy TODO. Verifikasi font brand final tetap mengikuti aset
resmi yang nanti diberikan, termasuk keputusan font Chinese brand.
