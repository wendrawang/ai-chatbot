# Migrasi host ke DesignKit

Lanjutan: [copy multilanguage dan komponen generik](DESIGNKIT_COPY_AND_COMPONENTS.md).

## Batas package dan atomic design

| Lapisan | Tanggung jawab |
| --- | --- |
| `Tokens/Generated` | Hasil export Figma; tidak diubah oleh integrasi ini |
| `Tokens`, `Theme`, `Typography`, `Foundations` | Nilai dasar, mapping semantik, font, tema, dan perhitungan ukuran |
| `Atoms` | Primitive visual: background, teks berformat, gambar, chart geometry, button style |
| `Molecules` | Gabungan primitive: text/image/status/information card dan legend |
| `Organisms` | Komposisi card lebih besar: chart, portfolio, receipt, financial list, HTML |
| `Support` | Parser, pengukuran layout, image loading, dan WebKit; bukan tingkatan atomic UI |
| `Models` | Data presentasi card reusable; tidak menjalankan operasi bisnis |

Approval dengan transaction/challenge/expiry, pilihan prompt, suggestion, action/deeplink,
dan handoff agent berada di **TanyaAIDomain**. View terkait berada di
**TanyaAIPresentation/Components/Chat**. DesignKit tidak bergantung pada fitur chat.
Atomic design adalah pembagian tanggung jawab; tidak perlu membuat lima lapisan
wrapper untuk setiap view. Screen, repository, login, dan navigasi tetap milik host/fitur.

Host yang memakai alias `TanyaAIAction`, `TanyaAIApprovalPayload`, `TanyaAISuggestion`
tetap memakai nama yang sama. Pemakai langsung tipe chat dari `DesignKit` perlu
mengganti import ke `TanyaAIDomain`/`TanyaAIPresentation`. Update **kedua package**
bersamaan untuk perubahan ini. Tidak perlu mengubah adapter Tencent/3Dolphins.

## 1. Startup: font dan tema

Daftarkan font sekali pada startup aplikasi, sebelum membuat typography branded:

```swift
import DesignKit

try DesignKitFont.registerFonts()
let themeManager = ThemeManager(fonts: .branded())
```

Contoh di atas berada dalam fungsi `throws` milik bootstrap host. Di AppDelegate,
tangani error dengan `do/catch` sesuai kebijakan startup aplikasi. Jika registrasi
gagal, pilih fallback `Theme.sandbox` secara eksplisit. Font package tidak perlu
ditambahkan ke `UIAppFonts` host. Simpan satu `ThemeManager` pada pemilik root;
jangan membuat manager baru di `body`.

## 2. Pasang pada container halaman

```swift
struct RootScreen: View {
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        AppContent()
            .theme(themeManager)
            .artworkLayout()
    }
}
```

`.artworkLayout()` mengukur lebar **container saat ini**, bukan layar global.
Pasang sekali pada root screen/content area yang mengisi ruang tersedia, bukan
pada tiap label atau di dalam row dengan tinggi intrinsik. Modifier memakai
`GeometryReader`; seperti container layout lain, ia mengambil ruang yang tersedia.
Sheet/kolom split view mandiri dapat memiliki modifier sendiri.

Urutan penting: `.artworkLayout()` berada di luar `.theme(...)`, sehingga font
menerima artwork scale sebelum di-resolve. Rotation dan resize menghitung ulang
nilai environment. Tidak ada observer layar global atau cache ukuran layar statis.

Default **375 × 812**, mengikuti angka pada foto kode. Jika frame Figma sebenarnya
**374 × 812**, cukup atur:

```swift
AppContent()
    .theme(themeManager)
    .artworkLayout(referenceSize: CGSize(width: 374, height: 812))
```

Rumus ukuran: `nilaiFigma × min(lebarContainer / lebarArtwork, maximumScale)`.
Pembulatan dilakukan ke piksel fisik berdasarkan `displayScale`, bukan bilangan
bulat point. Tinggi artwork adalah metadata referensi; tinggi layar tidak dipakai
sebagai faktor terpisah agar bentuk dan proporsi font tidak terdistorsi.

Default `maximumScale = 1.25` membatasi pembesaran pada iPad/landscape. Host dapat
memilih batas lain. Contoh 375pt → faktor 1; 414pt → 1.104; iPad 1024pt → 1.25.
Pada lebar referensi dan Dynamic Type `.large`, nilai dasar font/padding tetap 1:1
(dengan penyesuaian piksel). Ini bukan janji screenshot identik: font metrics,
safe area, line wrapping, dan pengaturan aksesibilitas tetap berlaku.

## 3. Ukuran padding, radius, ikon, stroke

```swift
struct AccountContent: View {
    @Environment(\.artwork) private var artwork
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: FigmaSize.spacingMedium.sizeInArtwork(artwork)) {
            Text("Rekening")
                .designFont(.headline)
            Text("Ringkasan rekening Anda")
                .designFont(.body)
        }
        .padding(FigmaSize.spacingLarge.sizeInArtwork(artwork))
        .foregroundColor(Color(theme.colors.primaryText))
        .background(Color(theme.colors.surface))
        .cornerRadius(CGFloat(12).sizeInArtwork(artwork))
    }
}
```

`sizeInArtwork(_:)` sengaja menerima context. Property global tanpa parameter
akan bergantung pada screen/window yang belum tentu sedang menampilkan view,
dan dapat berbenturan dengan extension lama host. Alternatif yang setara:
`artwork.size(FigmaSize.spacingLarge)`.

- Ukuran biasa: `artwork.size(value)` atau `CGFloat.sizeInArtwork(artwork)`.
- Stroke: `artwork.stroke(value)` menjaga minimal satu piksel untuk nilai positif.
- Area tap: `artwork.tapTarget()` menjaga minimal **44pt**, termasuk pada layar kecil.
- `.infinity`, rasio gambar, opacity, durasi, dan nilai bisnis tidak ikut diskalakan.
- Jangan menskalakan angka yang sudah di-resolve untuk kedua kalinya.
- Generated token tetap ukuran dasar; jangan menyimpan hasil konversi di sana.

## 4. Font dan line height

Komponen native memakai `.designFont(.body)` / `.headline` / `.button` / `.amount`,
yang mengambil font dari theme sekaligus leading opsional Figma. Jangan memberi
fixed height pada teks agar Dynamic Type dapat menambah jumlah baris.

`Fonts.branded()` dan `Theme.sandbox` menyimpan resep ukuran dasar.
`.theme(...)` menggabungkan artwork scale dengan `UIFontMetrics` **satu kali**,
dan mengulang resolusi dari resep asli ketika kategori teks berubah. Memasang
theme lagi pada UIHostingController sel tidak menggandakan skala.

Untuk typography host sendiri, gunakan initializer `Fonts` yang menerima delapan
`DesignKitTypography` (title, headline, body, subheadline, footnote, caption,
amount, button). Tiap resep menerima nama PostScript, size, text style,
fallback weight, dan optional `lineHeight`. Nama token host bebas; mapping tetap
di luar folder generated.

Initializer lama dengan delapan `UIFont` tetap tersedia dan diperlakukan sebagai
**snapshot final**; ukuran dasarnya tidak dapat ditebak. Migrasikan ke resep jika
menginginkan skala artwork dan perubahan Dynamic Type otomatis.

Untuk UIKit:

```swift
let artwork = ArtworkMetrics(
    containerSize: view.bounds.size,
    displayScale: view.traitCollection.displayScale
)
let resolved = themeManager.theme.resolved(
    artwork: artwork,
    traits: view.traitCollection
)
label.font = resolved.fonts.body
label.textColor = resolved.colors.primaryText
label.numberOfLines = 0
```

Hitung saat bounds valid, dan ulangi ketika bounds/trait yang relevan berubah.
Jangan mengambil `UIScreen.main.bounds` pada static initializer. Jika memakai
`swiftUIFont(relativeTo:)` langsung, SwiftUI menangani Dynamic Type; jangan
mengoper UIFont yang sudah diskalakan sebagai ukuran dasarnya.

## 5. Memilih tema

```swift
themeManager.selected = .premier  // atau .default / .private
```

Seluruh view dalam subtree `.theme(themeManager)` yang memakai semantic colors
akan mengikuti pilihan. Warna hardcoded di host tentu harus dimigrasikan dahulu.
`TanyaAIDependencies(theme:)` masih snapshot: oper `themeManager.theme` saat
membuka chat. Host tetap memakai `.tanyaAIHost(...)`; alur login dan tombol masuk
chat tidak berubah. Layout artwork sudah terpasang pada root chat/history/PIN.
Bridge UITableView meneruskan artwork dan image loader ke UIHostingController sel.

## 6. Gambar, HTML, dan lifecycle

Untuk konten gambar terautentikasi, buat loader per sesi login dengan session host:

```swift
let imageLoader = ImageLoader(session: pinnedSession, maximumPixelSize: 1536)
// SwiftUI umum: content.imageLoader(imageLoader)
// Chat: TanyaAIDependencies(..., theme: themeManager.theme, imageLoader: imageLoader)
// Logout, setelah melepas layar sesi:
imageLoader.removeAllImages()
```

Loader default chat terpisah per dependency graph. Cache decoded dibatasi 40 gambar /
32MiB (NSCache bersifat evictable), downsampling dilakukan sebelum display,
dan task view dibatalkan saat view dilepas. Clear memakai generation sehingga request
lama tidak dapat mengisi ulang cache yang sudah dibersihkan. Host mengelola sendiri
URLCache/cookie dari session-nya. Miss serentak pada URL yang sama masih dapat
membuat request terpisah; belum ditambahkan broker request atau reference counting.

HTML memakai data store nonpersistent, JavaScript mati, navigasi dibatasi,
CSP menolak resource jaringan dan hanya mengizinkan gambar inline `data:`.
Tinggi di-clamp 44–1200pt; fragmen lebih tinggi dapat di-scroll di dalam web view.
KVO dilepas saat dismantle, closure observasi weak, callback diperbarui saat update.
Font HTML mengikuti ukuran body dengan system font; font branded native belum
tertanam sebagai web font. Gunakan native card jika perlu tipografi brand persis.

Teks bawaan komponen memiliki resource Inggris/Indonesia. Bahasa mengikuti
localization aplikasi; host perlu mengiklankan bahasa yang didukung. Isi dari
backend tetap tanggung jawab backend. Animasi typing menghormati Reduce Motion.

## Verifikasi sebelum migrasi produksi

Jalankan `Scripts/verify.sh` pada Mac dengan akses simulator. Periksa font yang
benar, pilihan tema, ukuran 320/375/414pt, split view, Dynamic Type accessibility,
choices panjang, dan buka/tutup layar berulang memakai Instruments Allocations/Leaks.
Static review, compiler, dan unit test tidak membuktikan semua jalur bebas leak
atau semua device bebas masalah performa. Token hasil export host tidak diubah.
