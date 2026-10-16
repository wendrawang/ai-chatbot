# Starting point — aturan implementasi

Scope branch ini adalah migrasi bertahap: fondasi DesignKit, font package, dan
screen kosong dengan composer. iOS 15. Gunakan SwiftUI; UIKit hanya untuk editor
multiline terukur dan bridge presentasi terisolasi. Flow chat lengkap tetap
tersedia pada history/main.

## Header file

- Semua file kode yang dikelola repo (Swift, script, dan `.strings`) memiliki
  header nama file, module/package, dan `Created by Wendra on dd/MM/yy.`.
  File baru memakai tanggal pembuatan; jangan mengganti tanggal saat mengedit.
- `// swift-tools-version` dan shebang tetap pada baris pertama, sebelum header.
- Token generated juga memiliki header tersebut; perubahan ini hanya menambahkan
  header, tanpa mengubah token atau menghapus catatan asal/provenance. Saat export
  berikutnya, template engine perlu mengeluarkan header yang sama.
- Jangan menambahkan kredit pribadi ke lisensi/font pihak ketiga, binary,
  screenshot, atau file project yang dihasilkan Xcode/project generator.

## Token dan nilai

- `Tokens/Generated` milik export engine. Jangan edit manual atau menduplikasi
  nilainya. Gunakan satu sumber token/font untuk semua komponen.
- Padding/spacing memakai `FigmaSize.spacingSmall`, `spacingMedium`, `spacingLarge`,
  `spacingExtraLarge`, atau `spacingDoubleExtraLarge`, sesuai peran. Jangan memakai
  `spacing4/8/16/...`. Typography memakai nama role, bukan token numerik polos.
- `CustomSizes` hanya untuk ukuran yang belum mempunyai token dengan peran yang
  sesuai: diameter tombol, minimum tap, radius, shadow, jumlah baris, toleransi.
  Jangan membuat alias spacing generated atau memakai spacing sebagai radius.
- `InitialValues` menyimpan nilai awal bersama, seperti string kosong dan angka
  nol. UI/source tidak menuliskan literal angka/string default secara tersebar.
  `.zero`, `.infinity`, enum UIKit/SwiftUI dan Boolean control flow adalah nilai
  bernama/logika, bukan token desain baru. Bit mask/radix/ASCII di parser hex
  adalah algoritma format, bukan ukuran UI. Tests boleh memiliki fixture literal.
- `CustomBasePaletteColor` memiliki hex tambahan di luar palette generated.
  `CustomColors` mengatur penggunaan semantik/opacity. Warna yang sudah memiliki
  token Figma dipakai langsung; jangan disalin ulang sebagai custom color.
- `.scaledToArtwork`: round(nilai / (375 / lebar UIScreen.main)), tanpa cap.
  Reference height 812 hanya metadata. Stroke minimum satu pixel; tap minimum
  44 point. Opacity dan jumlah baris tidak di-scale. Tidak ada `sizeInArtwork` alias.

## Font, resource, copy

- Font berada di `Resources/Fonts`; filename dan PostScript di `FontFace`.
  Register sekali saat bootstrap melalui CoreText/`Bundle.module`, idempotent.
- Nama case menyertakan family dan weight: `firaSansRegular/Medium/SemiBold/Bold`
  dan `openSansRegular/Medium/Bold`. Jangan memakai case `.regular/.medium` yang
  ambigu antar-family. Tambahkan file asli beserta lisensi dan nama PostScript
  yang dibaca dari metadata; jangan menyamakan nama file dengan PostScript.
- Composer memakai token `typographySizeDisplaySmall14` dan leading role yang
  sama, hanya dengan `.scaledToArtwork`. Ukuran font/leading tidak mengikuti
  pengaturan Dynamic Type pengguna; jangan menambahkan `@ScaledMetric` atau
  UIFontMetrics. Editor dan placeholder menerima UIFont fixed yang sama.
  Glyph Chinese yang tidak ada di Open Sans menggunakan fallback native iOS.
- Copy fitur berada di resource `en`, `id`, `zh-Hans`. Screen membaca locale dari
  environment dan menyuplai label ke DesignKit. Tidak ada copy bisnis di DesignKit.
- Technical identifiers, SF Symbols, filename, resource key dan diagnostic prefix
  disimpan dalam catalog metadata. Artwork sementara mempunyai TODO penggantian.
- ThemeManager/CopyCatalog belum diperlukan pada tahap ini. Warna light Figma
  digunakan langsung. Tambahkan mekanisme baru saat ada kebutuhan tahap berikutnya.

## Komponen dan ownership

- Struktur `Components/<NamaKomponen>`, `Extensions/<Type>+<Responsibility>.swift`.
  Nama DesignKit umum, tanpa prefix fitur. Jangan membuat ViewModel per komponen.
- `let` untuk input, `@Binding` untuk state caller, `@State` untuk draft lokal.
  Screen memiliki margin luar; komponen memiliki padding dalam/surface/shadow.
- Tinggi editor satu sampai empat baris; teks berikutnya scroll. Button visual
  24, tap minimal 44. Kata panjang dan keyboard tidak menggeser action keluar.
- Composer memakai alignment bawah dengan minimum tinggi row yang sama pada
  field dan tombol: satu baris sejajar tengah, multiline mempertahankan tombol
  di bawah. Minimum row mengikuti font/leading/padding dan minimum tap target;
  jangan menambahkan state jumlah baris untuk mengubah alignment.
- Padding visual composer memakai `spacingLarge` (16 pada artwork 375). Hitung
  inset tiap sisi tap target dari `(tapSize - visualSize) / 2`, setelah scaling
  dan minimum tap diterapkan. Kurangi inset ini dari padding luar tombol dan
  jarak field/tombol; jangan menambahkannya lagi ke jarak visual. Pada 44/24,
  inset 10 menyisakan padding 6. Field memakai inset vertikal tersebut agar teks
  multiline tetap berjarak 16 dari border. Pengaturan ukuran teks pengguna tidak
  mengubah tinggi row atau batas empat baris composer.
- Hint memakai font input yang sama dan alignment `.leading` pada ZStack agar
  berada di tengah field saat kosong. Pertahankan geometri caret native pada
  semua state: kosong, mengetik dan sesudah hapus. Jangan memusatkan caret kosong
  secara terpisah ke bounds, karena referensinya berbeda dari baseline saat mengetik.
- `ChatScreen(onSend:)` mengosongkan draft hanya jika callback host mengembalikan
  true. Starter tidak mengirim network, tidak menyimpan atau log isi pesan.
- Integrasi host tetap `.tanyaAIHost(host)` + `host.present()`/`dismiss()`.
  Presentasi fullscreen dengan animasi samping, terpisah dari navigation stack
  host. Jangan menggantinya dengan NavigationLink atau push pada stack host.
  Host dimiliki AppState/session owner atau `@StateObject`, tidak dibuat di body.
- UI owners `@MainActor`; putus delegate pada dismantle dan hindari retain cycle.
- Private view sections berupa noun: `field`, `surface`, `actionButton`.
  Urutan environment, binding/state, input, init, body, sections, helper.
- Maksimal 250 baris/file, 50 baris fisik/method, 120 karakter/baris; Bool berawalan
  `is`. Jangan padatkan implementasi agar lolos batas.

## Validasi

- Format: `python3 Scripts/format_changed.py --base startingpoint`.
- Style: `Scripts/check_style.sh`; semua checks: `Scripts/verify.sh`.
- Regenerate project lewat `ruby Scripts/generate_project.rb`; jangan edit pbxproj.
- PR untuk tahap ini menuju `startingpoint`, bukan `main`. Jangan memasukkan
  session SDK, bubble, PreviewBook atau transaksi ke starter sebelum diminta.
