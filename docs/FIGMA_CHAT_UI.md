# UI Tanya AI dari Figma — tahap dummy

Tahap ini membangun tampilan dan interaksi dari delapan foto flow Figma dan enam foto chopping komponen. Backend
belum dipilih; tidak ada login SDK, provisioning group, atau transaksi nyata
yang ditambahkan. Mulai migrasi fondasi dengan
[DESIGNKIT_PHASED_MIGRATION.md](DESIGNKIT_PHASED_MIGRATION.md), lalu adopsi
bagian UI di bawah secara bertahap.

## Menjalankan contoh

```sh
./Scripts/run_sandbox.sh --figma
```

Mode ini membuka welcome berbahasa Indonesia dengan tiga quick action. Pilih
Cek Portofolio, kemudian ikuti action sampai tabel, pilihan produk, NAB,
ringkasan pembelian, dokumen, PIN host dummy, dan hasil transaksi. Tulis
pertanyaan bebas untuk melihat contoh bold, strike, warna, link, dan bullet.
Data tetap berada di `TanyaAITestSupport` dan Sandbox, bukan default komponen.
Target test support tidak boleh ikut aplikasi host Release.

## Mapping komponen

| Bagian Figma | Komponen DesignKit | Pemilik perilaku |
| --- | --- | --- |
| Kotak input dan send di dalam | `MessageComposer` | Draft lokal pada `ComposerSection`; screen memiliki margin luar |
| Sapaan, deskripsi, “Mulai dari sini” | `WelcomeContent` | Copy/aksi dari `WelcomeConfiguration` host |
| Cek Porto, Beli Valas, Surat Referensi | `QuickActionList` / `QuickActionRow` | Screen mengirim prompt; komponen melaporkan tap |
| Bubble user merah | `TextBubble(isUser: true)` | Screen menyimpan pesan secara kronologis |
| Jawaban bebas, inline style, bullet | `TextBubble(isUser: false)` / `RichText` internal | Parser native; URL diteruskan ke handler |
| Disclaimer kecil abu-abu | `TextBubble` dengan role caption dan warna sekunder | Blok `note` dari data |
| Tabel investasi dan risiko | `DataTable` / `DataTableData` | Data valid 1–3 kolom; lebar header dan semua baris sama |
| Action berikutnya di jawaban | `ActionPill` | Intent prompt/edit/destination/authorization milik fitur |
| Radio produk / pilihan terpilih | `OptionList` / `OptionRow` | Fitur menyimpan identifier pilihan dan read-only history |
| NAB, jumlah, perubahan, info | `MetricSummary` | Nilai display dan aksi info dari data |
| Identitas produk dan rincian biaya/total | `SummaryCard` / `ItemHeader` / `SummaryField` | Data tampilan; bukan perhitungan atau otorisasi |
| Dokumen belum/sudah disetujui | `AcknowledgementRow` | Hasil persetujuan dari halaman host |
| “Checking your investment…” | `ActivityStatus` | Event status/data dummy |
| Arrow kembali ke latest | `ScrollToLatestButton` | Coordinator daftar memiliki posisi scroll |
| Header dan timestamp | `NavigationHeader` / `DateSeparator` | Callback navigasi/format date milik fitur; status bar milik iOS |
| Background | `ChatBackdrop` | Artwork dummy dengan TODO penggantian |
| Gambar + caption | `MediaCard` | Media placeholder lokal; tidak menambah networking |
| Suggested prompt horizontal | `SuggestionList` + action | Intent/callback milik fitur |
| Underlined redirect / filled CTA | `LinkAction` / `FilledAction` | Routing tetap webview/deeplink host |
| Syarat & Ketentuan dan PIN | Halaman existing host | `onHostFlow` dengan completion ke chat yang sama |

Tidak ada ViewModel per bubble. DesignKit menerima nilai/`Binding` dan callback.
`ResponseBlocksView` menerjemahkan payload fitur ke komponen generik; screen
model memiliki sesi dan aturan interaksi. UIKit tetap terbatas pada daftar dan
editor yang membutuhkan pengukuran/scroll stabil untuk iOS 15.

## Bentuk jawaban dummy

Jawaban baru adalah blok berurutan, sehingga layout dapat berupa teks → tabel →
evaluasi → action, atau teks → summary → action. Format ini adalah seam UI
sementara, bukan kontrak backend/vendor final.

```json
{
  "messageIdentifier": "response-1",
  "response": {
    "blocks": [
      {"type": "text", "text": "[bold]Evaluasi:[/bold] asetmu cenderung defensif."},
      {
        "type": "table",
        "table": {
          "columns": [
            {"title": "Produk", "widthWeight": 2},
            {"title": "Risiko", "alignment": "trailing"}
          ],
          "rows": [{"cells": ["Batavia Dana Kas Maxima", "Rendah"]}]
        }
      },
      {"type": "note", "text": "Angka bersifat ilustratif."}
    ]
  }
}
```

Adapter dummy meneruskan JSON lewat:

```swift
onEvent?(.structuredPayload(name: "response", json: payloadData))
```

Jenis blok: `text`, `note`, `table`, `actions`, `options`, `metric`,
`summary`, `documents`, `activity`, `media`, `suggestions`. Action memakai
`presentation` opsional `outlined`/`link`/`filled`; default tetap outlined.
Kirim **Contoh komponen** untuk fixture media/actions/suggestions. Bentuk media
masih placeholder UI, bukan kontrak backend final.

[PreviewBook](PREVIEWBOOK.md) dijalankan dengan `--previewbook` untuk inspect
state masing-masing komponen, termasuk send/stop dan dummy artwork. Stop
menerima callback; adapter backend belum menyediakan cancellation di chat. Contoh lengkap ada di
`MockFigmaResponseFixture+Portfolio` dan `MockFigmaResponseFixture+Purchase`.
Katalog lama sudah dihapus: hanya `text` dan `response` yang dirender. Event konten
yang tidak dikenali menjadi fallback teks; bukan renderer kompatibilitas lama.

Tabel menolak lebih dari tiga kolom dan jumlah cell yang berbeda dari header.
`widthWeight` membagi lebar tersedia, bukan ukuran pixel masing-masing baris.
Nominal dapat rata kanan; teks membungkus secara vertikal tanpa HTML atau scroll
horizontal. Pada kategori Dynamic Type aksesibilitas, field disusun vertikal
per row supaya label/angka tetap terbaca. Model tetap maksimal tiga kolom;
layout tabel biasa mengikuti Figma. Tidak ada accordion pada tahap ini.
Footer total dapat memakai `leadingColumnSpan: 2` dengan cell kedua kosong,
sehingga label memakai lebar dua kolom dan nominal tetap sejajar kolom terakhir.
Span divalidasi; nilai pada cell yang digabung tidak boleh diam-diam disembunyikan.

## Rich text dan link

```text
[bold]Teks tebal[/bold]
[strike]Harga sebelumnya[/strike]
[color]Pertumbuhan positif|00AA55[/color]
[link]https://www.google.com|Buka Google[/link]
[link]ocbcid://mobile?type=portfolio|Lihat portofolio[/link]
• [bold]Tabungan:[/bold] IDR 45.000.000
1. Langkah pertama
```

Style dapat digabung/nested. Bullet memiliki marker terpisah agar baris kedua
sejajar dengan isi. Target link adalah metadata; hanya label yang tampil.
Target malformed, scheme berbahaya, dan tag belum lengkap saat streaming tidak
membuka browser. Renderer native mengembalikan `.handled` atau `.discarded`,
sehingga tidak ada fallback Safari.

HTTP/HTTPS diubah menjadi intent `.webview`; URL aplikasi menjadi
`.deeplink`. Host tetap memvalidasi scheme/host/domain. Sandbox membuka webview
offline untuk membuktikan routing tanpa bergantung pada jaringan.

## Posisi prompt dan riwayat pilihan

Prompt yang benar-benar dikirim pengguna ditempatkan dekat atas area daftar.
`ChatLayoutMetrics.previousAnswerPreview` menentukan ruang preview jawaban
sebelumnya, saat ini token 48. Urutan pesan tidak dibalik. Trailing inset
sementara memberi ruang ketika jawaban masih pendek, lalu berkurang ketika
jawaban bertambah panjang.

Drag manual membatalkan anchor. Arrow menghapus trailing inset lalu kembali ke
bawah sebenarnya. Restore history dan `initialPrompt` otomatis tetap parkir di
bawah; keduanya tidak dianggap gesture send pengguna.

Pilihan produk yang sudah digunakan tetap terlihat: selected hijau, opsi lain
abu-abu, seluruh group tidak dapat ditap ulang. Update/replay mempertahankan
hasil interaksi lama; pilihan historis tidak diaktifkan kembali. Action prompt
lama dinonaktifkan/dihilangkan setelah giliran berikutnya; destination tetap
dapat dibuka.

## Sesi baru dan integrasi host

API presentasi tetap `.tanyaAIHost(host)` dan `host.present()`.
Tambahkan `welcome`, `makeNewSession`, dan `onHostFlow` pada initializer host
yang sudah ada:

```swift
let host = TanyaAIHost(
    theme: selectedTheme,
    deeplinkScheme: "ocbcid",
    deeplinkHost: "mobile",
    welcome: welcomeConfiguration,
    makeSession: makeSessionForOpening,
    makeNewSession: makeEmptyConversation,
    onDestination: routeValidatedDestination,
    onHostFlow: presentExistingHostFlow,
    onDeeplink: handleExistingDeeplink
)
```

Nama function di contoh adalah milik aplikasi Anda, bukan API tambahan package.
Factory mengembalikan instance adapter baru yang membaca percakapan kosong.
Factory dapat mengembalikan adapter yang memulai provisioning async saat connect.
Mengembalikan object berbeda yang masih membaca group/percakapan lama **tidak**
menciptakan sesi backend baru.

Titik tiga mengganti screen/model ke welcome tanpa mengirim ulang
`initialPrompt`. Draft, scroll, radio, dan persetujuan sesi lama tidak terbawa.
Tanpa factory, tombol tidak aktif. Pemakai konfigurasi lama tanpa welcome tetap
mendapat entry history yang lama.

`onHostFlow(request, presenter, completion)` menerima:

- `.document`: reference dokumen, judul, dan destination opsional.
- `.authorization`: reference konfirmasi; tidak membawa PIN.

Host mempresentasikan halaman existing **dari presenter yang diberikan**.
Setelah halaman itu ditutup, panggil completion:

```swift
presenter.dismiss(animated: true) {
    completion(.success(TanyaAIHostFlowResult(status: .accepted)))
}
```

Untuk document, `.accepted` menandai dokumen hijau. Membuka lalu kembali tanpa
persetujuan harus mengembalikan `.cancelled`. Setelah semua dokumen disetujui,
aksi lanjut PIN tersedia. Host/backend melakukan otorisasi; `.processing`
atau `.completed` menyelesaikan state UI, dengan `message` opsional sebagai
hasil balik. Jangan mengembalikan sukses hanya karena digit PIN sudah lengkap
pada aplikasi produksi.

Completion diteruskan ke main queue, hanya sekali untuk request aktif.
Completion terlambat setelah ganti sesi diabaikan. Chat/draft tetap ada ketika
host kembali. Jalur legacy `onConfirmation` dan `onDestination` pada
`TanyaAIHost` tetap melakukan dismissal sebelum routing. Bila destination
harus tampil di atas chat, entry UIKit `TanyaAIModule.makeViewController`
menyediakan `onAction` tanpa dismissal, seperti contoh Sandbox.

## Batas visual dan UX yang belum final

Foto dipakai untuk mapping susunan dan state, bukan mengekstrak nilai Figma
yang presisi. Background lengkung, emblem, dan symbol quick action memakai
gambar native sementara. Ganti dengan asset export Figma melalui
`Bundle.module`; `WelcomeContent` menerima slot emblem melalui ViewBuilder.
Token/font brand produksi tetap berasal dari design system internal.
Demo memakai mapping `DefaultColorConstants` yang sudah ada dan font sandbox;
tidak menyalin palette atau font menjadi token kedua.

Bubble “Confirmed & ACK (tbd)” tidak ditambahkan karena UX belum menentukan
teks/perilakunya. Hasil transaksi dummy tampil sebagai jawaban setelah host.
Format timestamp ada di satu constant `ChatDateFormat.timestamp`.

## Verifikasi

Tes mencakup parsing/link native, validasi tabel dan layout, readonly/replay,
factory sesi baru, lifecycle callback, hasil host, prompt anchor, dan flow UI
Sandbox. Screenshot UI baru menggunakan nama `figma-*` pada attachment test.
Hasil pengujian dan screenshot: [FIGMA_CHAT_VALIDATION.md](FIGMA_CHAT_VALIDATION.md).
Real asset, VoiceOver/performa pada perangkat, dan integrasi backend nyata tetap
merupakan checkpoint rollout pada panduan migrasi.
