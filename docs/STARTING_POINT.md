# Tahap 1 — halaman kosong dan composer

Tuliskan implementasi per bagian, lalu jalankan checkpoint sebelum lanjut.
Target ini sengaja tidak mempunyai session SDK, ViewModel, backend, bubble,
welcome, rich text, table, transaction, ThemeManager, atau CopyCatalog.

## Tree

```text
Packages/
├── DesignKit/
│   ├── Package.swift
│   └── Sources/DesignKit/
│       ├── Tokens/
│       │   ├── Generated/                # export engine existing
│       │   ├── CustomSizes.swift         # ukuran tambahan
│       │   ├── InitialValues.swift       # nilai awal bersama
│       │   ├── CustomBasePaletteColor.swift
│       │   └── CustomColors.swift        # warna tambahan + opacity
│       ├── Extensions/
│       │   ├── CGFloat+Artwork.swift
│       │   └── Color+Hex.swift
│       ├── Typography/FontFace.swift + FontLoader.swift
│       ├── Resources/Fonts/
│       ├── Foundations/Assets + Accessibility/
│       └── Components/
│           ├── GrowingTextInput/         # bridge + BoundedTextView
│           └── MessageComposer/
└── TanyaAI/
    └── Sources/TanyaAI/
        ├── Chat/ChatScreen.swift + ChatCopy.swift
        ├── Host/                        # tanyaAIHost + fullscreen presentation
        └── Resources/en.lproj + id.lproj + zh-Hans.lproj/
```

## Urutan implementasi

1. Pasang package/resource dan pertahankan `Tokens/Generated` milik Anda.
2. Tulis `InitialValues`, `CustomSizes`, custom palette dan extension sizing/hex.
   Padding mengambil `spacingSmall/Medium/Large` langsung. `Color(hex:)` menerima
   RGB, RRGGBB atau AARRGGBB dan memakai fallback nonoptional untuk input invalid.
3. Daftarkan font dengan `FontFace.registerFonts()` saat bootstrap. `FontFace`
   memisahkan nama file dan nama PostScript; `FontLoader` memproses Bundle.module.
   Open Sans Regular/Medium dan lisensinya ada di package. Chinese menggunakan
   fallback glyph iOS; font Chinese brand final masih dapat diganti kemudian.
4. Buat `BoundedTextView`, lalu bridge `GrowingTextInput`. Intrinsic width tidak
   memaksa lebar konten; tinggi dibatasi empat baris, kemudian scrolling aktif.
5. Buat composer: placeholder, field, action, surface. `@ScaledMetric` mengubah
   font dari ukuran token dasar; UIKit dan placeholder memakai UIFont yang sama.
   Parent hanya memberi Binding, label, palette/font pilihan dan callback kirim.
6. Buat screen: draft `@State`, area kosong, composer di bawah, margin luar.
   Baca locale host, resolve resource label dan kirimkan ke komponen.
7. Pasang bridge `.tanyaAIHost(host)` pada root existing. Satu `TanyaAIHost`
   dimiliki host/AppState atau `@StateObject`; panggil `host.present()` untuk
   menampilkan feature fullscreen dengan animasi samping. Button kembali milik
   feature melakukan dismiss; navigation stack host tetap terpisah.

Screen menggunakan `ChatScreen(onSend:)`. Callback mendapat draft dan mengembalikan
Bool: true membersihkan draft, false mempertahankan teks/seleksi. Draft whitespace
menonaktifkan action. Callback belum mengimplikasikan pesan terkirim ke backend.

Untuk membuka feature di atas `NavigationView` host existing, lihat
[contoh integrasi host](HOST_INTEGRATION.md), termasuk bootstrap font dan bahasa.

## Menjalankan dan bahasa

`Scripts/run_sandbox.sh --language id`, `en`, atau `zh-Hans`. Tanpa override,
locale mengikuti app. Host bisa menerapkan `.environment(\.locale, Locale(...))`;
locale diteruskan dari root ber-modifier saat presentasi. `Bundle.module` milik TanyaAI
menyimpan copy, DesignKit tidak menyimpan copy fitur.

UI starter mengikuti light palette Figma; penggunaan theme/adaptive appearance
menjadi tahap terpisah. SF Symbol send adalah dummy dengan TODO penggantian asset.
Skala mengikuti lebar layar utama, sehingga sheet/split view memerlukan kebijakan
container sebelum diadopsi. Ukuran/shadow tetap dapat disesuaikan melalui token.

## Checkpoint

- Input satu sampai empat baris lalu scroll, termasuk kata panjang dan Chinese.
- Action tetap terlihat di atas keyboard, area tap minimal 44, visual 24.
- Draft hanya dibersihkan setelah host menerima callback.
- Label English/Indonesia/Chinese benar dan font tidak menjadi kotak glyph kosong.
- Dynamic Type terbesar tetap bisa digunakan, dan placeholder memakai font editor.

Setelah tahap ini diterima, tambahkan header/welcome, lalu bubble dan data. Migrasi
komponen existing ke `Legacy` bisa menjadi PR terpisah setelah fondasi stabil.
