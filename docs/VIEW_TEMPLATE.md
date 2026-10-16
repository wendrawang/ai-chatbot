# Pola view dan resource

Gunakan `MessageComposer`, `ScreenHeader`, dan `ChatScreen` sebagai contoh yang
berjalan. `body` menjelaskan susunan utama; bagian visual yang cukup panjang
dipisah menjadi properti private bernama benda, seperti `field`, `surface`, atau
`actionButton`. View kecil tidak perlu dipecah lagi hanya demi aturan.

## Urutan satu file view

1. Header file atas nama Wendra, import, lalu deklarasi view.
2. `@Environment` yang dibaca view.
3. `@Binding` untuk data caller dan `@State` untuk state lokal.
4. Input immutable `private let`, termasuk callback.
5. Initializer public dengan nama parameter yang jelas.
6. `body`, bagian visual private, kemudian helper/aksi.
7. Extension initializer tambahan hanya bila mengurangi pekerjaan caller.

Contoh komponen sederhana; semua label diberikan caller agar DesignKit tetap umum:

```swift
import SwiftUI

@MainActor
public struct ActionRow: View {
    private let title: String
    private let onTap: () -> Void

    public init(title: String, onTap: @escaping () -> Void) {
        self.title = title
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            Text(title)
                .padding(FigmaSize.spacingLarge.scaledToArtwork)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
```

Komponen memiliki padding dalam/surface sendiri. Screen memberi margin luar.
Jangan menambahkan padding yang sama pada dua level. Buat `struct View` terpisah
jika mempunyai tanggung jawab sendiri atau dipakai ulang; properti private cukup
untuk potongan layout lokal. ViewModel baru diperlukan ketika ada state/logic
fitur yang memang perlu dimiliki, bukan karena ada sebuah view.

## Screen berikutnya

Pakai composition `ScreenContainer` agar header, boundary/blur, scroll dan footer
konsisten. Isi `content`, `trailing`, dan `footer`; tidak perlu extend BaseScreen,
protocol layout atau BaseViewModel. Content tidak membungkus ScrollView vertikal
lagi. Lihat pemakaian lengkap pada `ChatScreen.swift` dan
[shared header](SHARED_HEADER.md).

Screen memiliki draft; `MessageComposer` menerima Binding dan callback. Presenter
host tetap `.tanyaAIHost(host)` dengan satu `TanyaAIHost` milik `@StateObject` atau
session owner. Host tidak dibuat ulang di `body`.

## Annotation yang digunakan

| API standar | Alasan |
| --- | --- |
| `@State` | Mempertahankan state lokal selama identitas view sama. |
| `@Binding` | Membaca/mengubah state milik caller. |
| `@Environment` | Membaca locale, dismiss, dan preferensi sistem. |
| `@StateObject` | Memiliki reference object yang harus stabil, seperti presenter host. |
| `@ViewBuilder` | Menyusun slot content/trailing/footer tanpa AnyView. |
| `@MainActor` | Menjaga pemilik UI dijalankan pada main actor. |
| `@main` | Entry point sandbox app. |

Tidak ada macro kustom, `@Observable`, `@Model`, `@Namespace`, atau `@ScaledMetric`
pada starter. R.swift adalah plugin build yang menghasilkan source Swift biasa.
Tidak perlu annotation baru untuk membuat komponen berikutnya.

## Localization otomatis

Tambahkan key yang sama pada `Localizable.strings` English, Indonesia, dan
Chinese Simplified di target pemilik copy, kemudian build. Fitur memiliki copy
fitur; sandbox memiliki copy demo. DesignKit menerima label dari caller.

```swift
@Environment(\.locale) private var locale

// Di dalam feature TanyaAI:
String(resource: R.string.localizable.chatSend, locale: locale)
```

`String(resource:locale:)` hanya menjembatani locale SwiftUI ke resource R.swift;
tidak menyimpan daftar key/bahasa. Bundle memilih terjemahan yang sesuai, termasuk
`zh_CN` ke `zh-Hans`, dengan English sebagai fallback. Pemanggilan diulang ketika
environment locale berubah. Untuk copy tanpa override locale, accessor native
`R.string.localizable.chatSend()` juga tersedia.

## Asset otomatis

Masukkan imageset ke `DesignKit/Resources/Assets.xcassets`, lalu build:

```swift
// Dari DesignKit:
Image(R.image.sendArrow)

// Dari target lain, gunakan module untuk menghindari bentrok dengan R lokal:
Image(DesignKit.R.image.moreMenu)
```

DesignKit memakai `RswiftGeneratePublicResources` karena asset dapat dipakai
fitur lain. TanyaAI dan sandbox memakai `RswiftGenerateInternalResources` agar
copy internal tidak menjadi API publik. Ketiganya memakai versi R.swift yang sama.
Jangan membuat enum nama asset/localization key atau mengedit R.generated.swift.
Source generated berada di build folder, bukan di repo.

R.swift 7.8.0 terkadang belum memperbarui accessor setelah perubahan resource
secara incremental. Jika nama baru belum muncul, jalankan Clean Build Folder
lalu build lagi. Saat Xcode meminta kepercayaan plugin untuk pertama kali,
setujui plugin R.swift package tersebut. Jangan mematikan validasi plugin global.

Tiga ikon PDF sementara memiliki TODO penggantian export resmi Figma di
`Assets.xcassets/README.md`. Font tetap memakai `FontFace` karena metadata nama
file dan nama PostScript berbeda; ketujuh font existing tetap dipertahankan.

## Aturan nilai

- `InitialValues`: hanya data kosong/default bersama (`emptyString`,
  `zeroInteger`, `zeroCGFloat`). Boolean ditulis langsung `true`/`false`.
- `FigmaSize`: spacing role `small/medium/large` dan typography generated.
- `CustomSizes`: ukuran/batas yang belum mempunyai role token, misalnya empat
  baris editor dan minimum tap target 44.
- `CustomColors`: semantik warna tambahan; hex hanya di custom base palette.
- Konstanta algoritma yang bukan data awal/ukuran disimpan private dekat pemiliknya.

Body tidak melakukan registrasi font, network, parsing berat, atau penyimpanan.
State scroll hanya Boolean saat boundary berubah. Potongan view private membuat
kode terbaca; pemisahan tersebut sendiri bukan jaminan performa. Ukur ketika
ada workload yang nyata, dan jalankan pemeriksaan layout/lifecycle existing
sebelum mengubah ownership atau layout bersama.
