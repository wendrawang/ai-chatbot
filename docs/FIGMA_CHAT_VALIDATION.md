# Verifikasi UI Figma dan migrasi DesignKit

Verifikasi simulator dilakukan pada 14 Oktober 2026, iPhone 17 Pro dengan iOS
26.5. Target kode tetap iOS 15. Ini pengujian UI/dummy; bukan bukti integrasi
vendor, transaksi produksi, atau pengukuran FPS di perangkat.

## Hasil pemeriksaan

| Pemeriksaan | Hasil |
| --- | --- |
| DesignKit: markup/link, typography, tabel/column span, sizing, layout, resource | 96 tes lulus |
| TanyaAI: repository, decoding, interaksi, anchor, navigasi, lifecycle, benchmark | 198 tes lulus |
| Sandbox: composer, scrolling, legacy navigation, PIN, bubble lama, Figma flow | 16 tes UI lulus |
| Recheck setelah penyesuaian fokus sesi baru dan fixture | 19 tes relevan lulus |
| Recheck Figma, posisi composer setelah keyboard, dan screenshot | 4 tes UI lulus |
| Recheck layout header halaman host dan flow dokumen/PIN/webview | 2 tes UI lulus |
| Recheck selected indicator tanpa dimming tambahan pada readonly history | 1 tes UI lulus |
| Adapter Tencent existing tanpa jaringan | 24 assertion SDK double lulus |
| Script payload group existing | 5 tes Python lulus |
| SwiftLint, batas file/method, formatter, design-system guard | Lulus |

Regresi lengkap mencakup 310 tes Swift/UI yang berbeda; recheck di tabel
mengulang tes terkait dan tidak dihitung sebagai tes tambahan. Generated token
tidak diubah. Project Sandbox diregenerasi melalui script, bukan edit pbxproj.

Kasus yang diverifikasi:

- Welcome dengan tiga quick action; sesi baru menghapus draft dan interaksi lama.
- Prompt baru dekat atas dengan preview jawaban sebelumnya. Jawaban bertambah di
  bawah, drag membatalkan anchor, arrow mencapai bawah tanpa trailing space palsu.
- Restore/initialPrompt tetap parkir di bawah. Kata panjang tidak menggeser send;
  composer tumbuh empat baris, kemudian scroll.
- Tabel 2/3 kolom berbagi lebar. Total dapat span dua kolom; span invalid tidak
  menghilangkan nilai. Tidak ada HTML untuk bullet atau tabel.
- Radio tetap terlihat, selected hijau, semua opsi historis nonaktif. Replay dan
  tap ganda tidak mengaktifkan atau mengirim ulang.
- Native link membuka webview/deeplink melalui host. Tidak ada fallback Safari.
- Dokumen memiliki state 0/1/2 accepted. Kembali tanpa persetujuan tidak menandai
  accepted. PIN memakai halaman host demo dan hasil kembali ke chat yang sama.
- Callback host duplikat/terlambat setelah pergantian sesi diabaikan. Tes teardown
  memeriksa model, table, coordinator, dan callback yang tidak mempertahankan owner.

## Screenshot

Gambar diambil dari attachment XCUITest, bukan mockup gambar buatan. Seluruh
konten transaksi/nama/nominal adalah dummy.

| Skenario | Bukti |
| --- | --- |
| Welcome, header, composer | [welcome](../Artifacts/Screenshots/figma-welcome-three-actions.png) |
| Sesi baru tanpa draft | [empty](../Artifacts/Screenshots/figma-new-session-empty.png) |
| Bullet dengan bold dan wrapping | [portfolio](../Artifacts/Screenshots/figma-portfolio-bullets.png) |
| Tabel investasi 3 kolom dan total | [table](../Artifacts/Screenshots/figma-investment-three-column-table.png) |
| Tabel risiko 2 kolom | [risk](../Artifacts/Screenshots/figma-product-two-column-table.png) |
| Radio sebelum dan sesudah dipilih | [unselected](../Artifacts/Screenshots/figma-product-options-unselected.png), [read-only](../Artifacts/Screenshots/figma-product-options-read-only.png) |
| Ringkasan NAB | [metric](../Artifacts/Screenshots/figma-product-nab-summary.png) |
| Ringkasan pembelian | [summary](../Artifacts/Screenshots/figma-purchase-summary.png) |
| Dokumen 0, 1, 2 disetujui | [none](../Artifacts/Screenshots/figma-documents-none-accepted.png), [one](../Artifacts/Screenshots/figma-documents-one-accepted.png), [both](../Artifacts/Screenshots/figma-documents-both-accepted.png) |
| Halaman host dokumen dan PIN | [document](../Artifacts/Screenshots/figma-existing-host-document-doc-terms.png), [PIN](../Artifacts/Screenshots/figma-existing-host-pin.png) |
| Hasil transaksi dummy | [result](../Artifacts/Screenshots/figma-transaction-result.png) |
| Prompt anchor + preview jawaban sebelumnya | [anchor](../Artifacts/Screenshots/figma-new-prompt-anchor-and-preview.png) |
| Arrow pada jawaban panjang dan kembali latest | [arrow](../Artifacts/Screenshots/figma-long-answer-latest-arrow.png), [latest](../Artifacts/Screenshots/figma-long-answer-latest.png) |
| Bold, strike, color, inline links | [text](../Artifacts/Screenshots/figma-native-formatted-reply.png) |
| Routing webview dan deeplink | [webview](../Artifacts/Screenshots/figma-inline-webview.png), [deeplink](../Artifacts/Screenshots/figma-inline-deeplink.png) |

## Checkpoint berikutnya

Gunakan [rencana migrasi bertahap](DESIGNKIT_PHASED_MIGRATION.md) untuk mulai
dengan Legacy, token, font, dan sizing pada repo internal. Source design system
lama belum tersedia dalam pilot ini, sehingga pemindahannya belum dilakukan.

Masukkan asset/logo/font asli dan nilai export Figma untuk verifikasi visual
presisi. Emblem/background/icon sementara dipisahkan dari aturan interaksi.
Lakukan VoiceOver, Reduce Motion, Dynamic Type, keyboard/rotasi, dan pengukuran
lifecycle/performa di perangkat yang menjadi target host. Tes teardown tidak
membuktikan semua integrasi produksi bebas memory leak.

Provisioning sesi backend dan otorisasi tetap milik host/backend yang dipilih.
UI dummy ini tidak mengirim PIN ke chat atau mengeksekusi transaksi.
