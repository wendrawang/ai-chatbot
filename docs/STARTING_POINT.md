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
   Package berisi Fira Sans Regular/Medium/SemiBold/Bold dan Open Sans
   Regular/Medium/Bold beserta lisensinya. Gunakan nama eksplisit seperti
   `.openSansRegular` atau `.firaSansMedium`; `.regular/.medium` lama diganti.
   Composer default memakai `.openSansRegular`. Chinese menggunakan fallback
   glyph iOS; font Chinese brand final masih dapat diganti kemudian. Pemetaan
   file/PostScript dan sumbernya ada pada [katalog font](../Packages/DesignKit/Sources/DesignKit/Resources/Fonts/SOURCES.md).
4. Buat `BoundedTextView`, lalu bridge `GrowingTextInput`. Intrinsic width tidak
   memaksa lebar konten; tinggi dibatasi empat baris, kemudian scrolling aktif.
   UIKit menentukan geometri caret/seleksi pada semua state. Jangan menggeser
   caret hanya saat kosong: posisinya harus tetap sama dengan saat mengetik.
5. Buat composer: placeholder, field, action, surface. Token ukuran dasar memakai
   `typographySizeDisplaySmall14` dengan leading 21 dari role yang sama.
   Font/leading hanya memakai `.scaledToArtwork`, tanpa `@ScaledMetric` atau
   UIFontMetrics. Pengaturan ukuran teks pengguna tidak mengubah ukuran composer.
   UIKit dan placeholder memakai UIFont fixed yang sama.
   ZStack field memakai `.leading` agar placeholder berada di tengah field,
   sementara geometri caret tetap mengikuti baseline native UIKit.
   Parent hanya memberi Binding, label, palette/font pilihan dan callback kirim.
   Field dan tombol mempunyai minimum tinggi row yang sama, sehingga satu baris
   sejajar tengah. HStack tetap memakai `.bottom`: ketika field membesar, tombol
   bertahan di bawah dan field tumbuh ke atas. Minimum row mengikuti font,
   leading, padding dan minimum tap target.
   Padding visual memakai `spacingLarge`: lingkaran 24 berada di tengah tap target
   44, sehingga inset tiap sisi `(44 - 24) / 2 = 10`. Padding di luar tap target
   menjadi `16 - 10 = 6`, agar jarak lingkaran ke border tetap 16. Field tetap
   berjarak 16 di kiri; inset vertikal field 10 ditambah padding luar 6 menjaga
   jarak teks multiline 16 di atas/bawah. Satu baris mengikuti pusat visual tombol.
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
- Pada artwork 375, padding visual 16, termasuk tombol kanan/bawah dan teks kiri/atas multiline.
- Draft hanya dibersihkan setelah host menerima callback.
- Posisi caret sama sebelum mengetik, setelah huruf pertama dan setelah draft dihapus.
- Label English/Indonesia/Chinese benar dan font tidak menjadi kotak glyph kosong.
- Composer tetap berukuran sama pada pengaturan teks normal maupun accessibility XXXL;
  placeholder memakai font editor. Artwork scaling tetap mengikuti lebar layar.

Setelah tahap ini diterima, tambahkan header/welcome, lalu bubble dan data. Migrasi
komponen existing ke `Legacy` bisa menjadi PR terpisah setelah fondasi stabil.
