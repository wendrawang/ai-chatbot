# Hasil verifikasi prototype — 16 Oktober 2026

Created by Wendra. Status: **draft untuk review**, belum memenuhi seluruh checklist
UI pada rule. Tidak ada transaksi atau request jaringan nyata.

| Pemeriksaan | Hasil |
|---|---|
| Build app, deployment iOS 15 | Berhasil, SDK iOS Simulator 27.1 / Xcode 27.1 (27A9275), arm64 |
| Build-for-testing harness/UI test bundle | Berhasil |
| Build-for-testing TanyaAI package dan DesignKit | Berhasil |
| Test sumber domain, flow, chat, PIN input, parser, lokalisasi pada macOS | 18 test lulus, 0 gagal melalui `Scripts/test_core.py` |
| Formatter + SwiftLint + SwiftSyntax | Lulus pada source prototype aktif; Allman, <=250 baris/file dan <=50 baris/method |
| Token generated dan tujuh font dibanding origin/main | Tidak berubah |
| File tracked yang dihapus | 0; daftar penghapusan menunggu pilihan Wendra |
| Smoke launch / tampilan awal iOS 26.5 SE | Berhasil; English, Indonesia, Chinese Simplified diperiksa melalui screenshot native |
| UI automation seluruh transfer dan composer empat baris | Belum dijalankan; test sudah dikompilasi |
| Runtime iOS 15 / Dynamic Type / stress scroll seluruh flow | Belum diverifikasi secara interaktif pada lingkungan ini |

Test yang dijalankan mencakup: validasi nominal tanpa inquiry, inquiry/retry,
receipt konsisten dengan quote, tap berulang tidak menambah inquiry/submit,
PIN rejection/retry, PIN input membersihkan digit dan mengunci completion ganda,
back dari PIN, note 25 grapheme (emoji keluarga/Chinese), pending/status tanpa
resubmit, stale inquiry setelah cancel, duplicate intent, satu flow aktif,
isolasi customer/session, restore authorizing sebagai review tanpa request,
resource tiga bahasa, nested/unknown/malformed/escaped tags, substring link,
unsafe scheme dan tag streaming yang terpotong.

`Scripts/test_core.py` menyalin sumber non-UI yang sama ke workspace sementara
macOS, termasuk resource/plugin aslinya. Ini menjalankan perilaku state/parser,
bukan pengganti pengujian UIKit/SwiftUI. Test composer/font iOS hanya dikompilasi.
Tidak ada klaim FPS produksi atau bebas seluruh memory leak dari hasil ini.

## Temuan yang diperbaiki

- Cell provider sebelumnya membaca property model saat @Published masih berada
  di willSet, sehingga pesan pertama belum tersedia dan tabel crash. Cell provider
  sekarang membaca state yang sama dengan snapshot diffable. Smoke launch diulang
  dan halaman berhasil tampil.
- Key resource `source` dan property copy `language` berbenturan dengan generated
  accessor/state. Keduanya dibedakan tanpa mengedit R.generated.swift.
- Input satu baris sempat lebih rendah daripada ikon. Field sekarang memiliki
  tinggi minimum yang sama dengan area tap 44pt; padding visual tombol tetap 16pt.
- Hosting cell menggunakan containment pada seluruh OS, detach saat offscreen,
  attach kembali saat tampil, dan mempertahankan controller untuk reuse.

## Batas lingkungan dan hal yang perlu dijalankan berikutnya

Xcode terpasang mengharapkan CoreSimulator 1174.9.2, sedangkan framework/service
sistem masih 1171.7.0. Xcode menonaktifkan destination simulator untuk test runner.
App masih dapat dipasang/dibuka pada simulator iOS 26.5 yang sudah booted, sehingga
smoke screenshot dapat diperiksa. Setup Xcode/system tidak diubah untuk melewati ini.

Setelah simulator cocok dengan Xcode, jalankan UI tests pada SE dan layar besar,
tiga bahasa serta accessibility Dynamic Type. Verifikasi input 1/4/>4 baris,
keyboard, pemilihan sumber/metode/keperluan, semua tahap transfer termasuk pending,
PIN back/close/scroll, link destination alert, history resume, dan scroll anchor.
Foto input/ringkasan/receipt yang disebut rule belum terlampir; layout mengikuti
hierarki tertulis dan tidak diklaim pixel-perfect terhadap foto tersebut.

## Screenshot native yang diperiksa

- [English SE](../Artifacts/Prototype/chat-en-SE.png)
- [Indonesia SE](../Artifacts/Prototype/chat-id-SE.png)
- [Chinese Simplified SE](../Artifacts/Prototype/chat-zh-Hans-SE.png)

Screenshot ini hanya tampilan awal/rich text/composer kosong. Belum menjadi bukti
visual alur input → summary → PIN → receipt atau input composer empat baris.
