# DesignKit: komponen dan aturan pemakaian

DesignKit tidak mengetahui Tanya AI, backend, produk bank, atau navigasi.
Public view menggunakan nama peran dan input tampilan generik. Katalog saat ini
hanya berisi primitive/komponen yang dipakai desain Figma terbaru, beserta
fondasi token, font, sizing, localization, rich text dan hosting UIKit.

## Katalog aktif

| Komponen | Kegunaan | Struktur/input |
| --- | --- | --- |
| `MessageComposer` | Kotak input multiline dengan send di dalam | Binding draft, enabled dan onSend; field/button/surface private |
| `GrowingTextInput` | Editor multiline satu–empat baris pada iOS 15 | Bridge UITextView terukur; tidak memegang sesi |
| `RichText` / `TextBubble` | Teks bergaya, link, bullet dan prompt user | String + callback link; parser native, tanpa HTML |
| `ScrollToLatestButton` | Tombol kembali ke pesan terakhir | Label + callback; pemilik scroll ada pada screen |
| `OptionRow` / `OptionList` | Pilihan aktif dan readonly history | SelectionOption, selected ID, enabled dan callback |
| `ActionPill` | Aksi outlined | Judul, simbol, enabled dan callback; tidak tahu deeplink |
| `ActivityStatus` | Status proses dengan simbol | Teks dari caller; tidak memegang task jaringan |
| `LoadingStateView` | Loading/error bootstrap | Label dari caller; pemilik state di fitur |
| `QuickActionRow` / `QuickActionList` | Entry action dengan judul/deskripsi/icon | QuickActionData + callback; reusable untuk halaman lain |
| `WelcomeContent<Emblem>` | Sapaan/deskripsi/daftar entry action | Copy/action dan artwork ViewBuilder; screen mengatur posisi/background |
| `DataTable` | Tabel dua/tiga kolom | DataTableData; satu pembagian lebar header/row/footer, teks membungkus |
| `ItemHeader` | Judul item dengan subjudul/detail/simbol | Nilai tampilan umum; tidak ada model produk bank |
| `MetricSummary` | Nilai utama dengan delta dan info | Judul/value/change dalam String, positivity, callback info |
| `SummaryCard<Header>` | Ringkasan fields dengan header | SummaryField + ViewBuilder header; pemilik transaksi tetap di fitur |
| `AcknowledgementRow` | Dokumen/persetujuan yang bisa dibuka | Judul, accepted, enabled, callback; keputusan accepted milik caller |
| `OutlinedBackground` / `DesignButtonStyle` | Primitive surface/button feedback | Visual theme dan ukuran; tanpa workflow |
| `HostingTableViewCell` / `LayoutTrackingTableView` | Bridge layout/lifetime UIKit | Generic Content; tidak menyimpan data bisnis |

Tidak ada ViewModel per komponen. `let` untuk nilai display, `@Binding` untuk
state milik caller, `@State` untuk interaksi/pengukuran lokal. Callback mengirim
intent ke screen. `ViewBuilder` pada welcome/summary memungkinkan ganti artwork
atau header tanpa menambah banyak flag yang tidak saling berkaitan.

`DataTable` mempunyai validasi jumlah kolom/cell/span di data model, sehingga
renderer tidak perlu memutuskan cara membuang kolom berlebih. Ukuran teks
aksesibilitas memakai field vertikal per row tanpa membuang kolom. Lebar diukur sekali
untuk seluruh baris; cell membungkus vertikal. Data numeric tetap berupa String
presentasi, perhitungan/format mata uang milik pemakai.

## Fondasi dan cara pasang

```swift
ContentView()
    .theme(selectedTheme)
    .copyCatalog(CopyCatalog(localeIdentifier: "id"))
```

Theme merupakan nilai environment; ThemeManager hanya dipakai bila pemakai
memerlukan pergantian theme teramati. Tidak ada singleton global wajib atau
artwork environment object. Font melalui `.designFont(role)` dan font family
terdaftar dari resource package.

Padding/spacing menggunakan `FigmaSize` langsung. Nilai yang belum tersedia
menggunakan `DesignKitMetrics.Size`, `Radius`, `Table`, `Shadow`, dan sebagainya.
`.sizeInArtwork` untuk artwork, `.tapTargetInArtwork` untuk touch area ≥44,
`.strokeInArtwork` untuk batas pixel. Opacity adalah nilai tanpa satuan.
Komponen mengatur padding dalam; screen mengatur margin luar.

Copy berupa input/label caller. Fallback teks memakai resource package, dan
CopyCatalog bisa memberi override per subtree tanpa mengubah window lain.
Accessibility label dibaca VoiceOver; identifier stabil dipakai automation.

## Scope migrasi

Chart, portfolio allocation, receipt, financial-list, HTML/image card, live
agent, pilihan multi-select, ResponseContent empat bagian dan keypad/PIN
internal sudah dihapus dari katalog. Komponen dokumen/PIN host dummy ada hanya
di Sandbox; aplikasi produksi memakai halaman existing host. Backend/vendor
examples lama juga tidak menjadi template migrasi saat ini.

Design system existing Anda dipindah ke `Legacy` sesuai
[plan bertahap](DESIGNKIT_PHASED_MIGRATION.md). `Legacy` menandai API lama yang
masih dipakai screen existing; bukan menghidupkan lagi katalog demo yang dihapus.
Repo existing belum dilampirkan, jadi inventory dan adapter Legacy belum
mengklaim implementasi konkret. Ikuti [template komponen](COMPONENT_STYLE.md).
