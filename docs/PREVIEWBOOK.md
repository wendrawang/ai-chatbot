# PreviewBook dan handoff komponen

PreviewBook adalah katalog SwiftUI di aplikasi Sandbox. File katalog hanya
mengimpor DesignKit/SwiftUI; tidak memerlukan sesi chat, Tencent, atau data
produksi. Fixtures, state interaktif, dan artwork dummy tinggal di Sandbox.

```sh
./Scripts/run_sandbox.sh --previewbook
```

Di Xcode, gunakan scheme `TanyaAISandbox` dan launch argument `--previewbook`.
Pilih komponen dari katalog. Untuk melihat media/action di percakapan penuh,
jalankan mode default dan kirim **Contoh komponen**. Flow pembelian sebelumnya
tetap dimulai dari **Cek Portofolio**.

## Struktur source

```text
DesignKit/
├── Components/<NamaKomponen>/<NamaKomponen>.swift
├── Foundations
├── Tokens/Generated
├── Tokens
├── Theme
├── Typography
├── Models
├── Resources
└── Support
```

Komponen Atoms/Molecules/Organisms dipindah berdasarkan nama peran. Import dan
nama public type tetap sama; folder bukan namespace atau performance boundary.
Tidak ada ViewModel per komponen. Helper yang memang bagian suatu komponen
diletakkan pada folder komponen tersebut.

Katalog dikelompokkan berdasarkan fungsi: input/selection, content, actions,
dan screen composition. Primitive surface/button feedback terlihat dalam
penggunaan; tidak perlu halaman kosong untuk setiap helper.

## State yang tersedia

| Halaman | Contoh |
| --- | --- |
| MessageComposer | Empty, typing, multiline, send, disabled, stop dengan/tanpa handler |
| OptionList | Active, selected hijau, readonly history, reset |
| TextBubble/RichText | Outgoing pendek/panjang, incoming, bold, strike, color, link, bullet/number, caption |
| MediaCard | Artwork slot, judul/deskripsi panjang |
| Actions | Outlined, underlined link, filled accent/custom tint, disabled, suggested horizontal |
| DataTable | Dua/tiga kolom, nominal trailing, footer total dengan span |
| MetricSummary | Positive, negative, informasi, nilai/delta panjang |
| SummaryCard/ItemHeader | Identitas item, fields, total, label panjang |
| AcknowledgementRow | 0/1/2 accepted, continuation sesudah lengkap |
| WelcomeContent | Emblem, sapaan, deskripsi, section title dan tiga QuickActionRow |
| NavigationHeader/DateSeparator | Control slots, centered title, formatted date, ScrollToLatestButton |
| Feedback | ActivityStatus pendek/panjang dan LoadingStateView |
| Artwork | Emblem besar/kecil, icon thumbnail dummy |

DateSeparator menerima String; format tanggal milik pemakai. Chat tetap memakai
satu constant `ChatDateFormat.timestamp`. NavigationHeader tidak menggambar
jam/sinyal/baterai; status bar dan safe area dimiliki iOS/screen.

## Artwork dummy dan TODO penggantian

Placeholder menggunakan SF Symbols, shape, dan gradient lokal; tidak ada download
atau dependency image-loading baru. Cari `TODO` di source:

- `PreviewArtwork`: banner, emblem dan thumbnail demo.
- `WelcomeSection` / `ChatBackdrop`: emblem dan background percakapan.
- `MessageComposer`, `QuickActionRow`, `ItemHeader`: icon send/stop, rekomendasi dan item.
- `ResponseBlocksView` / `ResponseBlocksView+Actions`: media dan emblem CTA.

TODO resource yang sengaja diminta diperbolehkan oleh lint. Mereka menandai
penggantian visual; bukan implementasi workflow yang disembunyikan.

Export Figma dimasukkan ke asset catalog bundle pemiliknya. Asset reusable
DesignKit memakai `Bundle.module`; asset khusus fitur/host tetap di bundle
fitur/host. MediaCard dan FilledAction menerima content melalui ViewBuilder;
lookup resource dan networking tidak masuk komponen.

```swift
MediaCard(title: title, subtitle: description) {
    Image("promotion", bundle: assetBundle)
        .resizable()
        .scaledToFill()
}

FilledAction(title: title, onTap: onTap, icon: {
    Image("emblem", bundle: assetBundle)
        .resizable()
        .scaledToFit()
})
```

MediaCard menjaga aspect ratio/clipping terpisah dari intrinsic size gambar.
Art dekoratif tidak mendapat accessibility label kedua; informasi penting dari
gambar perlu disediakan pada title/subtitle atau content yang sesuai.

## Spacing, size, dan batas perilaku

Padding/spacing mengambil FigmaSize langsung. Ukuran tambahan ada pada
DesignKitMetrics di luar generated, seperti `Radius.media` / `Media.aspectRatio`.
Sesuaikan token/resep font dan asset dari export final; foto bukan sumber pixel
yang presisi. Jangan mengedit generated manual. Margin luar milik screen,
padding dalam milik komponen.

Composer send tetap visual 24 dan touch area minimal 44. Saat `isGenerating`
aktif, callback `onStop` dipakai. Tanpa handler, stop disabled; tidak menjadi
send. Stop tidak bergantung pada draft, dan komponen tidak menghapus draft.
PreviewBook mensimulasikan callback. UI chat belum mengklaim pembatalan service
karena adapter backend belum dipilih.

Jawaban tetap berupa blok berurutan. Tambahan dummy: `media`, `suggestions`,
serta action `presentation` opsional `outlined`/`link`/`filled`. Action tanpa
presentation tetap outlined. LinkAction hanya melaporkan tap: web diarahkan ke
webview host, deeplink ke handler host. Media fixture memakai `symbolName`
sebagai placeholder; bukan kontrak backend final atau renderer remote image.

Dokumen/PIN produksi tetap milik host. Tap dokumen di PreviewBook mensimulasikan
accepted result untuk inspeksi state; chat menunggu completion host. Nilai PIN
tidak masuk DesignKit.

## Handoff UI/UX

Lengkapi properties state dan aturan resize. Copy, icon, dan artwork bisa
diganti; jawaban lengkap merangkai instance komponen yang sama. Tidak perlu
komponen baru untuk setiap kombinasi blok.

Catat padding dalam, margin luar, gap, radius, stroke, shadow, font/leading,
ukuran visual dan touch area terpisah. Sertakan teks panjang, multiline,
keyboard, selected/readonly, dua/tiga kolom dan total. PreviewBook menjadi
tempat memeriksa state sebelum adopsi screen demi screen.

## Validasi dan screenshot

[Hasil pengujian dan gallery native](FIGMA_CHAT_VALIDATION.md).
