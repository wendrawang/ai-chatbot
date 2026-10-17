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
6. `body`, kemudian bagian visual private yang menghasilkan `View`.
7. `private extension` pada file yang sama untuk helper setup/perhitungan/validasi.
8. `private extension` untuk handler/aksi bila diperlukan.
9. Extension initializer tambahan hanya bila mengurangi pekerjaan caller.

Deklarasi utama memperlihatkan susunan tampilan; extension memperlihatkan
perhitungan dan aksi pendukung. Gunakan `// MARK: - Helpers` dan
`// MARK: - Actions` agar pembagian terlihat di source dan navigator Xcode.
Contoh pada `MessageComposer`: `field`, `actionButton`, dan `surface` tetap di
struct utama; `inputFont`, `singleLineRowHeight`, `lineSpacing`, dan
`isSendEnabled` berada di private extension. `ChatScreen.close/submit` berada di
extension Actions.

Stored properties, `@State`, `@Binding`, `@Environment`, dan input callback tetap
di deklarasi utama. Extension tidak menambah stored property. Pertahankan
stored/computed semantics saat merapikan: jangan mengubah waktu perhitungan nilai
hanya untuk memindahkannya. Lifecycle `UIViewRepresentable` dan override UIKit
tetap pada tipe pemilik; helper seperti `applyStyle` dapat dipindahkan ke extension.
View tanpa helper tidak perlu extension tambahan. Pemindahan ke extension adalah
pengorganisasian source, tanpa penambahan object, state, atau cache saat runtime.

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

## Callback dan typealias

Callback sederhana ditulis langsung pada pemiliknya:

```swift
private let onBack: () -> Void
private let onSend: (String) -> Bool
```

Nama menyatakan aksi. Kontrak hasil wajib jelas: pada starter, `onSend` mengembalikan
`true` ketika host menerima submission sehingga draft boleh dibersihkan; `false`
mempertahankan draft. Ini bukan status sukses pengiriman ke backend.

Tidak perlu satu file `TypeAliases.swift` untuk `Action`, `VoidCallback`, dan
alias callback lain yang sudah mudah dibaca. Gunakan typealias ketika signature
cukup kompleks atau menjadi kontrak domain yang dipakai beberapa API. Letakkan
dekat domain pemilik, dengan nama sesuai tanggung jawab. Typealias hanya nama lain
untuk tipe; tidak memberi penghematan runtime.

Closure bisa mempertahankan reference object. Jika object menyimpan callback yang
menangkap object itu sendiri, gunakan capture yang sesuai, misalnya `[weak self]`.
Tidak perlu menambahkan weak capture pada setiap closure SwiftUI secara otomatis.

## Kapan dipindahkan menjadi komponen bersama

| Tanggung jawab | Tempat |
| --- | --- |
| Header, container, composer, editor umum | `DesignKit/Components` |
| Scroll boundary, sizing, locale resource | `DesignKit/Extensions` |
| Token, custom size/color, registrasi font | `DesignKit/Tokens` dan `Typography` |
| Draft, menu sesi, aturan menerima submission | Screen/fitur pemilik |
| Bridge presentasi TanyaAI | `TanyaAI/Host` |

Komponen umum yang sudah dibutuhkan beberapa caller dibuat reusable. Potongan
yang baru *mungkin* dipakai ulang boleh tetap private sampai tanggung jawabnya
jelas atau ada caller berikutnya. Saat memisahkan, kirim data dan callback dari
caller; jangan memasukkan nama screen, routing fitur atau state bisnis ke DesignKit.

Bagian rumit saat ini terisolasi: `GrowingTextInput`/`BoundedTextView` mengatur
measurement, seleksi dan delegate editor; `TanyaAIPushTransition` mengatur transisi
UIKit. Screen baru cukup memakai API publiknya. Lifecycle bridge mengikuti urutan
make/update/dismantle, dan delegate diputus saat dismantle. Komentar menjelaskan
alasan perilaku khusus, bukan mengulang arti setiap baris.

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
  baris editor dan ukuran visual tombol yang ditentukan UI/UX.
- `CustomColors`: semantik warna tambahan; hex hanya di custom base palette.
- Konstanta algoritma yang bukan data awal/ukuran disimpan private dekat pemiliknya.

Semua dimensi, termasuk frame tombol dan tebal stroke, memakai `.scaledToArtwork`
langsung dari token/nilai desain. Tidak ada minimum tap/stroke, pembesaran area
tap oleh SDK, atau kompensasi padding untuk frame interaksi tambahan. Padding
composer tetap memakai `spacingLarge` di semua sisi; ukuran interaksi mengikuti
desain UI/UX.

Body tidak melakukan registrasi font, network, parsing berat, atau penyimpanan.
State scroll hanya Boolean saat boundary berubah. Potongan view private membuat
kode terbaca; pemisahan tersebut sendiri bukan jaminan performa. Ukur ketika
ada workload yang nyata, dan jalankan pemeriksaan layout/lifecycle existing
sebelum mengubah ownership atau layout bersama.

Properti `private var field: some View` tetap dievaluasi bersama body pemiliknya;
ini bukan batas update tersendiri. Gunakan `struct View` terpisah bila bagian itu
memiliki state/dependency sendiri yang perlu diisolasi. Jangan menambah cache,
ViewModel, typealias, atau generic helper hanya dengan dugaan akan lebih cepat.
Batas empat baris membatasi tinggi editor; panjang teks tetap memengaruhi biaya
measurement. Pengujian paste panjang tidak berarti panjang input tak terbatas
akan selalu murah.
