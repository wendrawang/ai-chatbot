# Starting point — aturan implementasi

Scope branch ini adalah migrasi bertahap: fondasi DesignKit, font package,
screen kosong dengan composer, dan shared header dengan boundary/blur scroll.
Konten dummy untuk mengecek scroll hanya berada pada sandbox. iOS 15. Gunakan SwiftUI; UIKit hanya untuk editor
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
- Nilai desain di luar Figma dipisah per jenis, bukan dikumpulkan di satu file:

  | File | Isi | `.scaledToArtwork` |
  | --- | --- | --- |
  | `Generated/FigmaSize` | Spacing, ukuran icon, tipografi dari Figma. **Cek di sini dulu.** | Ya |
  | `CustomSizes` | Dimensi point yang belum ada di Figma: `Header.height`, `Shadow`, `Composer.sendButton` | **Selalu** |
  | `CustomTextLines` | Batas baris per peran: `composerInput = 1...4`, `headerTitle` | Tidak pernah |
  | `CustomMotion` | Durasi dan ambang gesture: `Navigation.duration`, `SwipeBack.velocity` | Tidak pernah |
  | `CustomColors` / `CustomBasePaletteColor` | Warna semantik tambahan / hex dasarnya | — |
  | `ArtworkScale` | Referensi 375×812 dan rasio layar untuk `.scaledToArtwork` | Tidak pernah |
  | `LayoutTolerance` | Toleransi pembulatan layout (bukan token desain) | Tidak pernah |

  Kelompok bersama dinamai per peran (`Header`, `Shadow`, `CustomTextLines.address`
  bila nanti dibutuhkan). Nilai yang hanya dipakai satu komponen memakai namespace
  nama komponen (`CustomSizes.Composer`) agar terhapus bersama komponennya. Tambah
  nilai baru hanya ketika ada pemakainya. `check_design_system.py` menolak
  `CustomSizes` tanpa `.scaledToArtwork` dan baris/motion/toleransi yang di-scale.
  Jangan membuat alias spacing generated atau memakai spacing sebagai radius.
- Nilai awal memakai nilai bawaan tipe: `.zero` untuk CGFloat/Int/TimeInterval,
  `String()` untuk string kosong, `[]` untuk koleksi. Tidak ada enum alias seperti
  `InitialValues`. Tulis tipe bila perlu: `var measuredHeight: CGFloat = .zero`.
  Boolean ditulis langsung `true`/`false`. Batas baris masuk `CustomTextLines`, dimensi
  masuk `CustomSizes`; konstanta algoritma yang bukan ukuran tetap private pada pemiliknya. UI/source
  tidak menuliskan literal angka/string default secara tersebar.
  `.zero`, `.infinity`, enum UIKit/SwiftUI dan Boolean control flow adalah nilai
  bernama/logika, bukan token desain baru. Bit mask/radix/ASCII di parser hex
  adalah algoritma format, bukan ukuran UI. Tests boleh memiliki fixture literal.
- `CustomBasePaletteColor` memiliki hex tambahan di luar palette generated.
  `CustomColors` mengatur penggunaan semantik/opacity. Warna yang sudah memiliki
  token Figma dipakai langsung; jangan disalin ulang sebagai custom color.
- `.scaledToArtwork`: round(nilai / `ArtworkScale.currentRatio`), rasio = 375 / lebar
  UIScreen.main, tanpa cap.
  Reference height 812 hanya metadata. Semua dimensi termasuk stroke dan area
  tombol memakai `.scaledToArtwork` langsung dari nilai desain. Jangan menambahkan
  batas minimum tap/stroke, hit frame tambahan, atau helper scaling terpisah.
  Ukuran interaksi mengikuti keputusan UI/UX. Opacity dan jumlah baris tidak
  di-scale. Tidak ada `sizeInArtwork` alias.

## Font, resource, copy

- Font berada di `Resources/Fonts`; filename dan PostScript di `FontFace`.
  Register sekali saat bootstrap melalui CoreText/`Bundle.module`, idempotent.
- Nama case menyertakan family dan weight: `firaSansRegular/Medium/SemiBold/Bold`
  dan `openSansRegular/Medium/Bold`. Jangan memakai case `.regular/.medium` yang
  ambigu antar-family. Tambahkan file asli beserta lisensi dan nama PostScript
  yang dibaca dari metadata; jangan menyamakan nama file dengan PostScript.
- Teks memakai preset peran `DesignTextStyle` (`Typography/DesignTextStyle+Roles.swift`)
  dengan `.designFont(.body)`; UIKit memakai `style.uiFont` dan `style.lineSpacing`.
  Jangan merakit `FontFace.font(size:)` + token di view; script menolaknya di luar
  `Typography`. Tambah peran baru (heading, button, hyperlink) saat ada pemakainya.
  Composer memakai `.body` (Display Small 14/21), hanya dengan `.scaledToArtwork`. Ukuran font/leading tidak mengikuti
  pengaturan Dynamic Type pengguna; jangan menambahkan `@ScaledMetric` atau
  UIFontMetrics. Editor dan placeholder menerima UIFont fixed yang sama.
  Glyph Chinese yang tidak ada di Open Sans menggunakan fallback native iOS.
- Copy fitur berada di resource `en`, `id`, `zh-Hans`. Screen membaca locale dari
  environment dan menyuplai label ke DesignKit. Tidak ada copy bisnis di DesignKit.
- Localization dan xcassets diakses melalui R.swift generated saat build, bukan
  enum pemetaan key/nama asset manual. DesignKit memakai plugin public resources;
  fitur dan sandbox memakai internal resources. Gunakan `String(resource:locale:)`
  untuk mengikuti environment locale, dan `Image(R.image.namaAsset)` untuk gambar.
  Jangan mengedit/commit R.generated.swift. Setelah menambah resource, build ulang;
  Clean Build Folder jika accessor belum diperbarui oleh plugin.
- Technical identifiers, filename/PostScript font dan diagnostic prefix tetap
  metadata eksplisit. Artwork sementara mempunyai TODO penggantian.
- Theme memakai environment SwiftUI standar, tanpa ThemeManager/singleton.
  Komponen membaca `@Environment(\.designColors) private var colors`; jangan
  menerima parameter `colors:` atau membuat `DefaultColorConstants()` sendiri.
  Untuk Tanya AI, host mengisi `tanyaAI.colors` dan `tanyaAI.locale` saat nilainya
  berubah (inquiry proposition, Localize_Swift); fitur yang terbuka langsung ikut.
  Screen DesignKit lain memasang `.designColors(_:)` di root-nya.
  Area yang harus bebas theme memakai `.defaultDesignColors()` pada subtree itu.
  CopyCatalog belum diperlukan.

## Komponen dan ownership

- Struktur `Components/<NamaKomponen>`, `Extensions/<Type>+<Responsibility>.swift`.
  Nama DesignKit umum, tanpa prefix fitur. Jangan membuat ViewModel per komponen.
- Identifier UI test dikelompokkan per komponen (`ComponentIdentifier.Header.title`,
  `ComponentIdentifier.Composer.send`). String identifier adalah kontrak UI test.
- Tidak ada alias untuk nilai sistem: `.clear`, bukan `CustomColors.transparent`.
- TanyaAI dipisah per tanggung jawab: `Chat/` (screen dan section), `Host/` (API
  untuk host), `Transition/` (gerak halaman). Folder baru seperti `Messages/` atau
  `Service/` dibuat saat file pertamanya ada, bukan lebih awal.
- Screen standar memakai composition `ScreenContainer` dari DesignKit: header,
  area scroll, trailing action dan footer. Container memiliki satu `isScrolled`
  dan ID coordinate space lokal. Jangan membuat inheritance/BaseScreen protocol, ViewModel
  layout atau navigation container tambahan. Content tidak menambahkan ScrollView
  vertikal lagi. Footer memiliki margin sesuai komponen caller.
- `ScreenHeader` tetap komponen standalone untuk layout dengan scroll owner lain
  seperti List. Label/aksi back dan trailing berasal dari caller. Material hanya
  saat scrolled, fallback opaque jika Reduce Transparency aktif. Status bar dan
  safe area tetap milik sistem.
- `.onScrollBoundaryChange(in:threshold:perform:)` reusable di DesignKit. Pasang
  pada root konten scroll setelah padding; ID sama dengan ScrollView owner.
  Callback memberi nilai awal lalu perubahan Boolean saja, tanpa state offset
  setiap pixel, global PreferenceKey atau AnyView. Jaga isolasi nested scroll.
- Utamakan API SwiftUI sederhana yang familiar bagi tim. Untuk identitas area
  scroll, gunakan `@State private var scrollSpaceID = UUID()`, tanpa `@Namespace`.
  State mempertahankan nilai ID selama view yang sama hidup. Jangan membuat ID
  baru di body atau memakai satu ID global untuk beberapa area scroll. Tambahkan
  konsep/property wrapper lain hanya ketika ada kebutuhan yang jelas.
- Menu/sesi adalah tanggung jawab fitur/host. `onNewConversation` hanya callback;
  tanpa handler, item menu disabled. Jangan menambah session, welcome, reset draft,
  intent, bubble atau database pada tahap header.
- `let` untuk input, `@Binding` untuk state caller, `@State` untuk draft lokal.
  Screen memiliki margin luar; komponen memiliki padding dalam/surface/shadow.
- Callback sederhana ditulis langsung (`() -> Void`, `(String) -> Bool`) dengan
  nama aksi dan kontrak hasil yang jelas. Typealias hanya untuk signature kompleks
  atau kontrak domain bersama, diletakkan dekat pemiliknya, bukan catalog global.
  Potongan yang baru mungkin reusable tetap private sampai tanggung jawab/caller
  berikutnya jelas; ekstrak komponen umum yang memang diperlukan.
- Tinggi editor satu sampai empat baris; teks berikutnya scroll. Ukuran tombol
  mengikuti nilai desain, tanpa minimum tap tambahan. Kata panjang dan keyboard
  tidak menggeser action keluar.
- Composer memakai alignment bawah dengan minimum tinggi row yang sama pada
  field dan tombol: satu baris sejajar tengah, multiline mempertahankan tombol
  di bawah. Tinggi row satu baris mengikuti font/leading dan ukuran visual tombol;
  jangan menambahkan state jumlah baris untuk mengubah alignment.
- Padding composer di semua sisi dan jarak field/tombol memakai `spacingLarge`
  (16 pada artwork 375), tanpa kompensasi area tap. Frame tombol mengikuti ukuran
  visual desain. Pengaturan ukuran teks pengguna tidak mengubah tinggi row atau
  batas empat baris composer.
- Hint memakai font input yang sama dan alignment `.leading` pada ZStack agar
  berada di tengah field saat kosong. Pertahankan geometri caret native pada
  semua state: kosong, mengetik dan sesudah hapus. Jangan memusatkan caret kosong
  secara terpisah ke bounds, karena referensinya berbeda dari baseline saat mengetik.
- `ChatScreen(onSend:)` mengosongkan draft hanya jika callback host mengembalikan
  true. Draft dimiliki `ComposerSection` (`@State`), bukan `ChatScreen`, agar setiap
  ketikan tidak me-render ulang header dan daftar pesan. Starter tidak mengirim
  network, tidak menyimpan atau log isi pesan.
- Integrasi host tetap `.tanyaAIHost(host)` + `host.present()`/`dismiss()`.
  `TanyaAIHost` menampilkan `ChatScreen` langsung; jangan menambahkan wrapper
  `HostedChatScreen`, NavigationView/NavigationStack atau toolbar native di SDK.
  Presentasi `.overFullScreen` dengan animasi samping dan swipe-back interaktif,
  terpisah dari navigation stack host. View host tetap di window tetapi disembunyikan
  selama tertutup, sehingga SwiftUI tetap memproses perubahan root (main → prelogin)
  dan anchor yang hilang menutup fitur. Jangan menggantinya dengan NavigationLink
  atau push pada stack host. `present()` mengembalikan Bool; setiap completion
  `dismiss` dijalankan setelah fitur benar-benar tertutup, termasuk yang datang
  saat dismiss sedang berjalan. Host dimiliki AppState/session owner atau
  `@StateObject`, tidak dibuat di body.
- UI owners `@MainActor`; putus delegate pada dismantle dan hindari retain cycle.
- Private view sections berupa noun: `field`, `surface`, `actionButton`.
  Deklarasi utama berurutan environment, binding/state, input, init, body, sections.
  Computed setup/perhitungan/validasi berada di `private extension` pada file yang
  sama, dengan `// MARK: - Helpers`. Handler memakai `// MARK: - Actions` dan
  private extension tersendiri bila ada. Stored properties/property wrapper tetap
  pada deklarasi utama; jangan mengubahnya menjadi computed hanya agar pindah.
  Lifecycle protocol/override UIKit tetap pada tipe pemilik. Jangan membuat
  extension kosong atau memisahkan setiap helper menjadi extension sendiri.
- Ikuti [template view](docs/VIEW_TEMPLATE.md). Property wrapper SwiftUI standar,
  `@ViewBuilder`, `@MainActor`, dan `@main` pada app mempunyai peran jelas.
  Jangan menambahkan macro kustom, `@Observable`/`@Model`, wrapper baru atau
  inheritance hanya untuk menyeragamkan layout.
- Maksimal 250 baris/file, 50 baris fisik/method, 120 karakter/baris; Bool berawalan
  `is`, kecuali nama wajib protocol seperti `PreferenceKey.defaultValue` dengan
  pengecualian lint lokal beralasan. Jangan padatkan implementasi agar lolos batas.

## Validasi

- Format: `python3 Scripts/format_changed.py --base startingpoint`.
- Style: `Scripts/check_style.sh`; semua checks: `Scripts/verify.sh`.
- Regenerate project lewat `ruby Scripts/generate_project.rb`; jangan edit pbxproj.
- PR untuk tahap ini menuju `startingpoint`, bukan `main`. Jangan memasukkan
  session SDK, bubble, PreviewBook atau transaksi ke starter sebelum diminta.
