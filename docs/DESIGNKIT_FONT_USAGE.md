# Memakai font DesignKit di TanyaAI dan host

Font bundled: Fira Sans Regular/Medium/SemiBold/Bold dan Open Sans
Regular/Medium/Bold. Resource sudah dipaketkan oleh SwiftPM. Tambahkan produk
DesignKit sebagai dependency target host jika host akan mengimpor DesignKit.
Jangan mengedit Tokens/Generated untuk setup font.

## 1. AppDelegate: register sekali sebelum membuat theme

Tambahkan `import DesignKit`, lalu panggil dalam didFinishLaunchingWithOptions:

```swift
do {
    try DesignKitFont.registerFonts()
} catch {
    // Teruskan kegagalan konfigurasi ke mekanisme diagnostics host.
    // UIFont menggunakan fallback sistem jika font tidak terdaftar.
    print("DesignKit font registration failed: \(error)")
}
```

Tidak perlu `UIAppFonts` di Info.plist untuk font bawaan ini. Loader memakai
Bundle.module dan CoreText scope process. Registrasi sukses dicache berdasarkan
URL dan dilindungi NSLock; pemanggilan ulang tidak mendaftarkan font yang sama.
Jangan menjalankan registrasi di View.body atau untuk setiap bubble/token.

## 2. Saat menyiapkan TanyaAIHost: berikan theme branded

Registrasi font tidak otomatis mengganti Theme.sandbox. Di prepareTanyaAI,
setelah membangun composition yang sudah ada, gunakan:

```swift
let fonts = Fonts.branded()
let chatTheme = Theme(tokens: DefaultColorConstants(), fonts: fonts)

tanyaAIHost = composition.makeHost(
    theme: chatTheme,
    silentGreeting: nil,
    onDeeplink: { [weak self] destination in
        self?.pendingChatDeeplink = destination
    }
)
```

Snippet tersebut berada di AppState sesuai flow host: Main memanggil persiapan
host setelah profil tersedia. Main tetap menggunakan `.tanyaAIHost(...)` dan
entry point memanggil `.present()`. Semua bubble yang memakai theme mendapat
font yang sama tanpa mengatur font satu per satu.

Jika host sudah mempunyai ThemeManager, gunakan snapshot manager tersebut:

```swift
let manager = ThemeManager(fonts: .branded(), selected: .premier)
let chatTheme = manager.theme
let fixedTheme = manager.resolve(isDefaultForced: true)
```

Jalankan ThemeManager pada main actor. Pilih chatTheme untuk mengikuti pilihan
manager atau fixedTheme untuk halaman yang selalu default; kedua pilihan tetap
memakai font branded. Simpan manager di pemilik app/session, bukan di body.
Premier/Private dalam repository masih palette dummy.

TanyaAIHost menyimpan snapshot theme. Mengubah manager sesudah host dibuat tidak
mengubah host tersebut otomatis. Buat host baru dengan snapshot baru ketika chat
sudah ditutup; jangan mengganti host di tengah presentasi.

## 3. Mapping font default branded

| Role | Font | Ukuran dasar token |
| --- | --- | --- |
| title | Fira Sans Bold | 32 |
| headline | Fira Sans SemiBold | 20 |
| body | Open Sans Regular | 16 |
| subheadline | Open Sans Regular | 14 |
| footnote / caption | Open Sans Regular | 12 |
| amount | Fira Sans Bold | 24 |
| button | Fira Sans Medium | 16 |

Ukuran diambil dari FigmaSize, bukan angka yang disimpan ulang di loader.
Open Sans menggunakan PostScript name OpenSansRoman-* dalam resource saat ini.
Gunakan DesignKitFont.postScriptName, jangan menebak nama dari nama file.

## 4. Pemakaian dalam komponen DesignKit

Komponen SwiftUI membaca font semantik dari theme:

```swift
import DesignKit
import SwiftUI

struct AmountCaption: View {
    @Environment(\.theme) private var theme

    var body: some View {
        Text("Total saldo")
            .font(Font(theme.fonts.body))
    }
}
```

Untuk komponen SwiftUI yang memerlukan custom font dengan scaling langsung:

```swift
let typography = DesignKitTypography(
    postScriptName: DesignKitFont.openRegular.postScriptName,
    size: FigmaSize.typographySizeDisplayNormal16,
    style: .body
)

Text("Informasi rekening")
    .font(typography.swiftUIFont(relativeTo: .body))
```

UIKit memakai typography yang sama:

```swift
label.font = typography.font(compatibleWith: label.traitCollection)
label.adjustsFontForContentSizeCategory = true
```

Fonts.branded() membuat snapshot UIFont yang sudah diskalakan saat dibuat.
Perubahan ukuran teks aksesibilitas setelahnya membutuhkan snapshot font/theme
baru untuk jalur itu. Jangan menganggap tema snapshot pada chat yang sudah
terbuka otomatis mengikuti perubahan kategori ukuran. API swiftUIFont(relativeTo:)
memakai scaling native SwiftUI.

## 5. Mengubah pilihan font

Buat Fonts sendiri dengan delapan role (title, headline, body, subheadline,
footnote, caption, amount, button), lalu masukkan ke Theme atau ThemeManager.
Gunakan DesignKitTypography untuk setiap role. Mapping default dapat dibaca di
Typography/Fonts+Generated.swift; file itu berada di luar Tokens/Generated.

## Performa dan batas pemeriksaan

Registrasi font/CoreText dan cache URL merupakan resource seumur hidup proses,
bukan cache per-bubble. Tujuh file bundled didaftarkan sekali. Jangan mendaftarkan
URL font baru secara tak terbatas karena loader mempertahankan daftar URL sukses.

Audit layout memeriksa cell terlihat sebelum mengukur tinggi baru. Pembaruan
beruntun dikoaleskan, subscription dan callback memakai weak capture, dan table
reference coordinator bersifat weak. Test regression menguji pertumbuhan bubble,
serta pelepasan table/coordinator/message saat height update masih terjadwal.

Hasil pengujian simulator tidak menjamin nol memory leak pada host + SDK vendor.
Untuk production, periksa buka/tutup chat berulang dan streaming panjang pada
perangkat target memakai Instruments Allocations/Leaks dan Time Profiler.
