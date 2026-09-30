# Theme dan font DesignKit

`ThemeManager` memilih `.default`, `.premier`, atau `.private`. Satu instance dimiliki
app root; view membacanya lewat `.theme(manager)`. Tidak ada singleton global.

## Status token

`Tokens/Generated` sementara berisi snapshot yang ditranskripsikan dari foto:
`FigmaColorProtocol`, `DefaultColorConstants`, dan `FigmaSize`. Ini **bukan** export
asli engine. `PremierColorConstants` dan `PrivateColorConstants` adalah **dummy**,
sesuai instruksi untuk pengembangan. Warna brand dummy belum untuk produksi.

Saat export asli tersedia, ganti file snapshot dengan hasil engine secara utuh.
Jangan memperbaiki nama, format, atau nilai secara manual di folder generated.
Mapping ada di `Theme/Theme+Generated.swift`, typography di `Typography/`, dan
alias spacing/stroke di `Tokens/DesignKitMetrics.swift`.

Folder generated dikecualikan dari aturan panjang nama/file karena engine memiliki
kontrak sendiri; semua kode integrasinya tetap mengikuti aturan proyek.

## Startup dan pilihan tema

Daftarkan font sebelum membuat theme. Jalankan setup ini sekali pada main actor,
misalnya saat menyiapkan dependency aplikasi:

```swift
import DesignKit

try DesignKitFont.registerFonts()
let themeManager = ThemeManager(fonts: .branded())
themeManager.selected = .premier
```

`registerFonts()` melempar error jika resource hilang/rusak; tangani error pada
startup host. Registrasi berulang aman dan tidak membaca ulang file yang sudah
berhasil didaftarkan. Resource font ada di bundle Swift Package, sehingga host
**tidak perlu** menambahkan `UIAppFonts` untuk font ini.

Contoh pemakaian SwiftUI:

```swift
struct AccountPage: View {
    @ObservedObject var manager: ThemeManager

    var body: some View {
        AccountContent()
            .theme(manager)
    }
}
```

Komponen membaca `@Environment(\.theme)`. Ketika `manager.selected` berubah,
modifier memperbarui environment; sel chat yang memakai environment tersebut juga
dimuat ulang jika warna/font berubah. Pemilik manager harus mempertahankan instance
(misalnya `@StateObject` di root SwiftUI), bukan membuatnya di `body`.

## Halaman yang selalu default

```swift
PaymentPage()
    .theme(themeManager, isDefaultForced: true)
```

Override hanya berlaku pada subtree halaman tersebut. Pilihan global tetap
Premier/Private dan halaman lain tidak berubah. Untuk memaksa seluruh aplikasi:

```swift
themeManager.isDefaultForced = true
// Pilihan tetap disimpan; saat dilepas, tema pilihan kembali berlaku.
themeManager.isDefaultForced = false
```

Di UIKit atau API yang menerima nilai `Theme`, ambil snapshot:

```swift
let selectedTheme = themeManager.theme
let fixedTheme = themeManager.resolve(isDefaultForced: true)
```

`TanyaAIDependencies(theme:)` saat ini menerima snapshot. Jika pilihan berubah,
berikan snapshot baru saat membuka fitur berikutnya. Modifier SwiftUI di atas
bersifat live; snapshot UIKit tidak otomatis berlangganan ke manager.

## Memakai palette host sendiri

```swift
let fonts = Fonts.branded()
let manager = ThemeManager(
    defaultTheme: Theme(tokens: DefaultColorConstants(), fonts: fonts),
    premierTheme: Theme(tokens: PremierColorConstants(), fonts: fonts),
    privateTheme: Theme(tokens: PrivateColorConstants(), fonts: fonts)
)
```

Adapter menerima `FigmaColorProtocol`, sehingga penggantian export tidak perlu
mengubah komponen UI selama kontrak token tetap sama. Jangan menduplikasi seluruh
protocol menjadi protocol kedua. Mapping semantik (misalnya accent ke
`colorsButtonActive`) hanya ada di satu tempat.

## Font dan Dynamic Type

Tersedia Fira Sans Regular/Medium/SemiBold/Bold dan Open Sans Regular/Medium/Bold.
File asli diambil dari Google Fonts, dengan lisensi OFL disertakan.
Nama file tidak selalu sama dengan nama PostScript: Open Sans yang dibundel
menggunakan `OpenSansRoman-*`. Gunakan `DesignKitFont.postScriptName`.

```swift
let bodyStyle = DesignKitTypography(
    postScriptName: DesignKitFont.openRegular.postScriptName,
    size: FigmaSize.typographySizeDisplayNormal16,
    style: .body
)
let labelFont = bodyStyle.font(compatibleWith: traitCollection)
let textFont = bodyStyle.swiftUIFont(relativeTo: .body)
```

`font(compatibleWith:)` memakai `UIFontMetrics`. `swiftUIFont(relativeTo:)` memakai
SwiftUI custom font relatif terhadap text style. Ukuran berasal dari generated
tokens; tidak ditulis ulang ke loader. UIKit memakai system fallback jika nama font
tidak ditemukan; test memastikan semua font bundled ditemukan tanpa fallback.

`Fonts.branded()` menghasilkan snapshot UIFont untuk kategori ukuran saat dibuat.
Untuk host UIKit yang mengubah kategori ukuran saat runtime, buat ulang `Fonts`
dan theme pada perubahan `preferredContentSizeCategory`. SwiftUI yang memakai
`swiftUIFont(relativeTo:)` mengikuti Dynamic Type secara langsung.

Untuk resource font lain:

```swift
let names = try FontLoader.register(
    fileNames: ["Custom-Regular.ttf"],
    bundle: resourceBundle,
    subdirectory: "Fonts"
)
```

Hasil berupa nama PostScript sebenarnya. Loader menggunakan registrasi CoreText
scope `.process`, tidak memasang font ke perangkat secara global.
