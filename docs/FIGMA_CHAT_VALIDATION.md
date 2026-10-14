# Validasi UI Figma dan stress test

Pengujian 14 Oktober 2026 setelah katalog lama dibersihkan. Data dummy;
backend/vendor dan transaksi nyata belum diuji. Semua screenshot adalah hasil
render native simulator, bukan mockup gambar.

## Hasil

| Pemeriksaan | Hasil |
| --- | --- |
| DesignKit: markup/link, font, sizing, table/span, layout dan hosting lifetime | 81 tes lulus |
| TanyaAI: decoder, session/delivery, options readonly, host flow, prompt anchor, new session, lifetime | 116 tes lulus |
| Figma UI pada iPhone SE 375×667 | 7 tes UI lulus |
| UI stress ulang dengan Dynamic Type accessibility XXXL pada SE | 3 tes UI lulus |
| Recheck UI normal: purchase, stress responses, host navigation | 3 tes UI lulus |
| SwiftLint, formatter, panjang file/method, guard DesignKit/copy | Lulus |

Tes layout DesignKit menjalankan **64 kombinasi**: delapan komponen × lebar
320/375/430/768 point × ukuran teks normal/aksesibilitas terbesar. Kombinasi
tersebut merupakan satu tes matrix, bukan 64 tes tambahan. Total regresi unik
**205 tes**: 81 DesignKit + 116 TanyaAI + 8 UI (7 Figma + 1 host navigation). Pengujian UI ulang
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
