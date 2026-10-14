# Tanya AI UI Sandbox

Referensi Figma terbaru dengan data dummy, iOS 15. Backend/vendor belum dipilih.
Gunakan `docs/FIGMA_CHAT_UI.md`, `docs/DESIGNKIT_PHASED_MIGRATION.md` dan
`docs/COMPONENT_STYLE.md` sebagai sumber scope dan style saat ini.

## Boundary

- DesignKit adalah package mandiri, dependency satu arah TanyaAI → DesignKit.
- Tidak boleh ada kata Tanya pada tipe/file/copy DesignKit, atau import fitur/SDK.
- Nama komponen sesuai peran, misalnya `DataTable`, `SummaryCard`, `OptionRow`.
- Nilai/binding/state lokal/callback untuk komponen. ViewModel untuk workflow async.
- SDK-neutral `TanyaAIChatSession` adalah seam backend; repository mengirim event
  ke main queue. Send acknowledgement terpisah dari jawaban bot.
- UIKit dibatasi pada presentasi terpisah, editor iOS 15, dan hosting daftar pesan.
  SwiftUI untuk layout. Table memakai UIHostingConfiguration pada iOS 16+,
  controller containment sebagai fallback iOS 15.
- Dokumen/PIN existing milik host: `onHostFlow` memberi request dan completion.
  Jangan membangun PIN/otorisasi internal atau menyimpan/log nilai PIN.
- Scope UI hanya teks dan blok response berurutan; renderer lama sudah dihapus.
  Jangan menambah compatibility layer untuk katalog lama tanpa kebutuhan pemakai.

## Perilaku UI

- Welcome disuplai host; tiga quick action pada fixture, menu titik tiga untuk
  percakapan baru. Sesi baru kembali ke welcome dengan draft kosong.
- Bubble user merah, assistant tanpa background. Rich text native, bullet/number
  hanging indent, bold/strike/color/link. Tidak menggunakan HTML renderer.
- Tabel maksimal tiga kolom, shared widths, nominal trailing dan footer span.
- Pilihan yang dipilih tetap readonly sebagai history: centang hijau, opsi lain
  abu-abu. Replay tidak mengaktifkan pilihan lama.
- Prompt user baru dekat atas dengan preview jawaban sebelumnya; urutan history
  tetap kronologis. Drag membatalkan anchor; arrow kembali ke actual latest.
- Composer putih, stroke/shadow, radius 8, send visual 24, touch target ≥44.
  Draft lokal pada ComposerSection, bukan publikasi setiap ketikan ke seluruh graph.
- Halaman host/destination menjaga aturan validasi/routing. Link web diarahkan ke
  webview host, deeplink ke handler host. Tidak memakai Safari fallback.

## Token, sizing dan copy

- Komponen visual ada di `Components/<NamaKomponen>`. Katalog `--previewbook`
  hanya untuk Sandbox. Dummy artwork menggunakan TODO penggantian asset.
- Media/action/suggestions terbaru adalah blok UI, tanpa network image loader
  atau cancellation backend palsu. Stop composer adalah callback dari pemakai.

- Padding/spacing ambil FigmaSize langsung bila tersedia. Ukuran khusus di
  DesignKitMetrics, nama berdasarkan peran, tanpa alias duplikat generated.
- Jangan edit Tokens/Generated; hanya ganti dengan export engine.
- `.sizeInArtwork` membaca referensi hardcoded 375×812, skala lebar layar
  dibatasi 1.25; tidak ada artwork environment object/root modifier.
- Stroke `.strokeInArtwork`, tap `.tapTargetInArtwork`; opacity tidak di-scale.
- Text memakai `.designFont(role)`; editor memakai font/leading yang sama.
- Localized/injected UI copy, aset/font dari Bundle.module. Data dummy hanya
  di Sandbox/TestSupport. Target test support tidak masuk Release host.

## Style wajib

- Variabel 3–35 karakter; boolean berawalan `is`. Pengecualian lokal hanya
  untuk nama protocol SDK yang memang wajib.
- Maksimal 250 baris/file, 50 baris fisik/method, 120 karakter/baris.
  Pecah extension per tanggung jawab; jangan padatkan agar lolos batas.
- Urutan: environment, binding/state, immutable input, init, body, visual section,
  helper. Nama private section noun seperti `header`, `field`, `actionButton`.
- Komponen owns inner padding/fill/stroke/shadow; screen owns outer margins.
- `@MainActor` pada UI owners/public entry points; weak captures untuk cycle.
- Jangan edit pbxproj manual. Setelah sumber Sandbox ditambah/dihapus, jalankan
  `ruby Scripts/generate_project.rb`.
- Format lewat `python3 Scripts/format_changed.py --base origin/main`; lint lewat
  `./Scripts/check_style.sh`. `./Scripts/verify.sh` menyapu paket dan UI tests.
- Tests menguji perilaku, layout, lifetime dan batas data; bukan setiap computed var.
  Jangan menyebut simulator benchmark sebagai FPS produksi.

## Catatan implementasi

UITableViewController juga menambah inset keyboard; message list memakai plain
UIViewController agar keyboard/safe-area cukup dimiliki SwiftUI. Restore history
parkir di bawah pada update yang sama, bukan async satu frame terlambat. Bounded
parking passes/coalesced weak work menjaga loop dan lifetime. Factory session
mengembalikan instance baru; deinit model melepas callback dan disconnect.
Deeplink yang membuka stack host harus menunggu completion dismissal.
