# Validasi UI Figma dan stress test

Pengujian 14 Oktober 2026 setelah cleanup dan penambahan chopping/PreviewBook. Data dummy;
backend/vendor dan transaksi nyata belum diuji. Semua screenshot adalah hasil
render native simulator, bukan mockup gambar.

## Hasil

| Pemeriksaan | Hasil |
| --- | --- |
| DesignKit: markup/link, font, sizing, table/span, layout dan hosting lifetime | 83 tes lulus |
| TanyaAI: decoder, session/delivery, options readonly, host flow, prompt anchor, new session, lifetime | 118 tes lulus |
| UI pada iPhone SE 375×667: 8 Figma + 1 host + 4 PreviewBook | 13 tes UI lulus |
| PreviewBook dengan Dynamic Type accessibility XXXL pada SE | 4 tes UI lulus |
| PreviewBook normal setelah pembatasan feedback/header glyph | 4 tes UI lulus |
| Recheck tampilan final: katalog + media/link/suggestions | 2 tes UI lulus |
| Recheck katalog final dengan font accessibility XXXL | 1 tes UI lulus |
| SwiftLint, formatter, panjang file/method, guard DesignKit/copy | Lulus |

Tes layout DesignKit menjalankan **128 kombinasi**: enam belas komponen × lebar
320/375/430/768 point × ukuran teks normal/aksesibilitas terbesar. Kombinasi
tersebut merupakan satu tes matrix, bukan 128 tes tambahan. Total regresi unik
**214 tes**: 83 DesignKit + 118 TanyaAI + 13 UI (8 Figma + 1 host navigation + 4 PreviewBook). Pengujian UI ulang
mengulang kasus relevan; tidak dihitung sebagai tes unik baru.

Layar normal juga direcheck setelah perubahan metrik/tabel/ikon, termasuk alur
pembelian/dokumen/PIN dummy dan presentasi pada stack navigasi host existing.
Detail hasil recheck dicatat pada description PR.

## Kasus stress

- Composer: newline sampai enam baris, kata 128 karakter tanpa spasi,
  keyboard aktif, area tap ≥44, lebar field tetap dan send tidak terdorong keluar.
- Konten: judul/deskripsi sangat panjang, reference tanpa spasi, nominal besar,
  delta negatif, tiga kolom dengan numeric trailing dan footer span dua kolom.
- Interaksi: pilihan readonly tidak bisa dikirim ulang, opsi terpilih tetap
  terlihat, new session menghapus draft, manual scroll dan return-to-latest.
- Welcome: ketiga quick action tetap dapat dijangkau dengan font terbesar.
- Lifetime: 25 siklus rendered chat/dismiss, 150→100 pesan, eviction,
  callback tertunda, hosting-cell containment dan teardown.

## Perbaikan dari pemeriksaan visual

1. Nilai metrik panjang tidak dipaksa berbagi lebar dengan delta. Bila tidak
   muat, delta berada di bawah; metrik pendek tetap inline sesuai Figma.
2. Ikon send/latest/check memakai ukuran artwork, sehingga font aksesibilitas
   tidak membuat ikon melebihi batas kontrol. Area sentuh tetap minimal 44.
3. Tabel memakai field vertikal per row pada kategori teks aksesibilitas.
   Kolom logis tetap maksimal tiga dan semua data tersedia. Tampilan normal
   tetap tabel dengan shared widths sesuai Figma.
4. Placeholder composer satu baris dengan ellipsis; label aksesibilitas tetap
   lengkap. Draft multiline tetap tumbuh sampai empat baris lalu scroll.

5. Slot control header mempunyai width/height tetap, sehingga content fleksibel
   tidak membuat header membesar tanpa batas.
6. Group aksesibilitas composer/page mempertahankan identifier kontrol anak;
   send/stop dan feedback tetap dapat ditemukan automation.
7. Action memakai radius terukur untuk multiline; rounded ends satu baris
   tetap sesuai pill, sementara teks panjang tidak keluar dari fill.

## PreviewBook dan chopping

Katalog berisi 26 komponen visual pada `Components/<NamaKomponen>`. PreviewBook
memiliki 13 halaman; helpers tampil dalam penggunaan. Tambahan media,
underlined/filled action dan suggestions juga diuji di percakapan, termasuk
routing webview dan prompt berikutnya. Semua artwork masih dummy dengan TODO
penggantian. Spacing/size memakai fondasi token yang sama.

[Menjalankan PreviewBook dan mengganti asset](PREVIEWBOOK.md).

## Screenshot

Screenshot flow normal yang sudah ada tetap di `Artifacts/Screenshots/figma-*.png`.
Screenshot stress ukuran normal dan ukuran aksesibilitas diberi prefix terpisah.

| Tampilan | Normal | Aksesibilitas terbesar |
| --- | --- | --- |
| Tabel | [normal](../Artifacts/Screenshots/figma-stress-table.png) | [reflow](../Artifacts/Screenshots/figma-stress-a11y-table-top.png) |
| Metrik | [normal](../Artifacts/Screenshots/figma-stress-metric.png) | [besar](../Artifacts/Screenshots/figma-stress-a11y-metric.png) |
| Ringkasan | [normal](../Artifacts/Screenshots/figma-stress-summary.png) | [besar](../Artifacts/Screenshots/figma-stress-a11y-summary.png) |
| Pilihan/dokumen | [normal](../Artifacts/Screenshots/figma-stress-options.png) | [besar](../Artifacts/Screenshots/figma-stress-a11y-options.png) |
| Input + keyboard | [normal](../Artifacts/Screenshots/figma-stress-composer-keyboard.png) | [besar](../Artifacts/Screenshots/figma-stress-a11y-composer-keyboard.png) |
| Welcome | [normal](../Artifacts/Screenshots/figma-stress-welcome.png) | [besar](../Artifacts/Screenshots/figma-stress-a11y-welcome.png) |

## Batas pengujian

Simulator iOS 26.5: iPhone SE 3rd generation dan iPhone 17 Pro. Deployment
minimal iOS 15 tetap diperiksa saat compile, dengan fallback hosting lifecycle
diuji secara terpisah. Belum merupakan runtime/device pass iOS 15 atau pengukuran
rendered FPS perangkat. Benchmark display link hanya cadence callback simulator.

Brand emblem/background/icon saat ini placeholder native. Palette/font demo
belum menggantikan export aset/font brand asli; hasil ini bukan sertifikasi
pixel-perfect terhadap Figma. Repo design system existing belum tersedia untuk
menguji adapter Legacy konkret. Integrasi backend serta UI dokumen/PIN produksi
memakai implementasi host ketika tersedia.

## Screenshot chopping dan PreviewBook

24 screenshot ukuran normal dan 24 ukuran font aksesibilitas terbesar tersimpan
di `Artifacts/Screenshots/previewbook/{normal,accessibility}`. Dua screenshot
`figma-components-*` memperlihatkan komponen baru di percakapan. Semua diambil
dari UI tests native; sampel utama diperiksa secara visual dan gambar tidak diedit.

| Contoh | Normal | Accessibility XXXL |
| --- | --- | --- |
| Media | [Lihat](../Artifacts/Screenshots/previewbook/normal/previewbook-media.png) | [Lihat](../Artifacts/Screenshots/previewbook/accessibility/previewbook-media.png) |
| Action / link / CTA | [Lihat](../Artifacts/Screenshots/previewbook/normal/previewbook-actions-scrolled.png) | [Lihat](../Artifacts/Screenshots/previewbook/accessibility/previewbook-actions-scrolled.png) |
| Composer / stop | [Lihat](../Artifacts/Screenshots/previewbook/normal/previewbook-composer-stop.png) | [Lihat](../Artifacts/Screenshots/previewbook/accessibility/previewbook-composer-stop.png) |
| Pilihan readonly | [Lihat](../Artifacts/Screenshots/previewbook/normal/previewbook-options-readonly.png) | [Lihat](../Artifacts/Screenshots/previewbook/accessibility/previewbook-options-readonly.png) |
| Tabel | [Lihat](../Artifacts/Screenshots/previewbook/normal/previewbook-table.png) | [Lihat](../Artifacts/Screenshots/previewbook/accessibility/previewbook-table-scrolled.png) |

Hasil final lokal: `/tmp/figma-chopping-designkit-release.xcresult`,
`/tmp/figma-chopping-package-final.xcresult`, `/tmp/figma-chopping-ui-v2.xcresult`,
`/tmp/figma-chopping-previewbook-final.xcresult`,
`/tmp/figma-chopping-accessibility.xcresult`, `/tmp/figma-chopping-gallery.xcresult`,
dan `/tmp/figma-chopping-accessibility-gallery.xcresult`.

Simulator SE dikembalikan ke text size large sesudah tes. Validasi ini belum
menggantikan real device/VoiceOver/integrasi backend pada minimum iOS 15.
