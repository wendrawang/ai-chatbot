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

## 2. Tema pada root; ukuran tanpa setup

```swift
struct RootScreen: View {
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        AppContent()
            .theme(themeManager)
    }
}
```

Tidak perlu `.artworkLayout()`, `.artwork(...)`, `GeometryReader`, maupun
`@Environment(\.artwork)`. Ukuran memakai properti `CGFloat` yang bisa langsung
dipanggil seperti extension existing host: `value.sizeInArtwork`.

Reference **375 × 812** di-hardcode pada `DesignKitMetrics.Artwork.referenceSize`,
di luar generated token. Skala mengikuti lebar `UIScreen.main` saat properti
dibaca, sehingga tidak menyimpan ukuran layar startup. Tinggi referensi tetap
metadata; tinggi layar tidak dikalikan terpisah.

Rumusnya `round(nilaiFigma × min(lebarLayar / 375, 1.25))`, mengikuti pembulatan
point pada extension existing. Batas skala 1.25 tetap menjaga pembesaran pada
layar lebar. Contoh: 16pt pada layar 375pt → 16pt; layar 414pt → 18pt.
Ini merupakan kebijakan ukuran berbasis layar: sheet sempit atau split view
memakai faktor layar yang sama, tanpa konfigurasi container per subtree.

## 3. Ukuran padding, radius, ikon, stroke

```swift
struct AccountContent: View {
    let title: String
    let detail: String
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: FigmaSize.spacing8.sizeInArtwork) {
            Text(title).designFont(.headline)
            Text(detail).designFont(.body)
        }
        .padding(FigmaSize.spacing16.sizeInArtwork)
        .foregroundColor(Color(theme.colors.primaryText))
        .background(Color(theme.colors.surface))
        .cornerRadius(DesignKitMetrics.Radius.card.sizeInArtwork)
    }
}
```

- Ukuran biasa: `value.sizeInArtwork`, tanpa argumen atau modifier root.
- Stroke: `value.strokeInArtwork` menjaga minimal satu piksel untuk nilai positif.
- Area tap: `value.tapTargetInArtwork` menjaga minimal **44pt**.
- `.infinity`, rasio gambar, opacity, durasi, dan nilai bisnis tidak ikut diskalakan.
- Jangan menskalakan hasil yang sudah di-resolve untuk kedua kalinya.
- Generated token tetap ukuran dasar; konversi tidak ditulis ke generated token.

Gunakan satu extension `CGFloat.sizeInArtwork` pada host. Bila host sudah
mendefinisikan nama yang sama, konsolidasikan implementasinya saat mengadopsi
DesignKit agar kebijakan ukuran host dan komponen tetap konsisten.

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
let resolved = themeManager.theme.resolved(
    traits: view.traitCollection
)
label.font = resolved.fonts.body
label.textColor = resolved.colors.primaryText
label.numberOfLines = 0
```

Resolusi default memakai layar saat ini; ulangi saat ukuran layar atau trait
yang relevan berubah. `ArtworkMetrics` tetap kalkulator nilai murni untuk test,
bukan environment object atau state yang harus dipasang oleh host. Jika memakai
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
chat tidak berubah. Chat/history/PIN memakai properti ukuran yang sama.
Bridge UITableView meneruskan theme, copy, dan image loader ke UIHostingController sel.

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
