# Membuka Tanya AI dari host app

API tahap minimal adalah `ChatScreen(isEnabled:onSend:)`. Modifier `.tanyaAIHost`
dari flow sebelumnya tidak ada di branch `startingpoint`; untuk tahap ini host
langsung menampilkan screen dan menyediakan callback kirim.

## Package dan font

Tambahkan product `TanyaAI` ke target host. Jika host memanggil API font secara
langsung, tambahkan juga product `DesignKit` dari package DesignKit yang sama
dengan dependency TanyaAI, agar tidak mempunyai dua salinan package/token/font.

Daftarkan font sekali pada bootstrap host, sebelum menampilkan screen:

```swift
import DesignKit

try FontFace.registerFonts()
```

Panggil dari konteks bootstrap yang menangani `throws` atau `do/catch` milik host.
Jangan menggunakan `try?` yang menyembunyikan kegagalan registrasi. Contoh lengkap
`do/catch` ada pada [StartingPointApp.swift](../TanyaAISandboxApp/StartingPointApp.swift).
Font dibaca dari `Bundle.module` DesignKit; host tidak perlu menyalin file font
atau menambahkan font package ke `UIAppFonts`.

## Menggunakan NavigationView existing

Letakkan `NavigationLink` di dalam `NavigationView` yang sudah dimiliki host.
Contoh berikut menerima label lokal dan handler dari host:

```swift
import SwiftUI
import TanyaAI

@MainActor
struct ChatEntryView: View {
    let title: String
    let onSend: (String) -> Bool

    var body: some View {
        NavigationLink {
            ChatScreen(onSend: onSend)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            Text(title)
        }
    }
}
```

`ChatEntryView(title:onSend:)` dipasang di screen/menu existing. `title` disuplai
dari localization host, misalnya label menu Tanya AI. Tidak perlu membuat
`NavigationView` kedua di dalam destination. Header/back button mengikuti
navigation host; custom header Figma menjadi tahap implementasi berikutnya.

Untuk pemeriksaan tampilan saja, handler `{ _ in true }` menerima draft dan
mengosongkan input. Handler `{ _ in false }` mempertahankan draft. Belum ada
pengiriman backend, bubble atau pembuatan session pada starter ini.

## Host yang mengatur presentasi sendiri

Jika router host sudah melakukan push/present, destination-nya cukup:

```swift
ChatScreen(onSend: onSend)
```

`onSend` adalah closure `(String) -> Bool` dari host, dipanggil pada main actor.
`true` berarti host menerima submission lokal untuk diproses, bukan konfirmasi
bahwa request network berhasil. Untuk proses async, host dapat memasukkan draft
ke antrean miliknya dan segera mengembalikan status penerimaan. `isEnabled`
dapat disuplai host ketika perlu mematikan tombol kirim.

## Bahasa dan appearance

Secara default screen mengikuti locale environment host. Jika aplikasi mempunyai
pengaturan bahasa sendiri, teruskan locale tersebut pada destination:

```swift
ChatScreen(onSend: onSend)
    .environment(\.locale, selectedLocale)
```

`selectedLocale` bertipe `Locale` dari pengaturan host. Copy package tersedia
untuk `en`, `id`, dan `zh-Hans`. Daftarkan bahasa yang didukung host di konfigurasi
localization target. Jika host belum mendeklarasikan semua bahasa package,
`CFBundleAllowMixedLocalizations = YES` memungkinkan resource dependency ikut
dipilih ([dokumentasi Apple](https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleallowmixedlocalizations)).
Contoh konfigurasi ada pada [Info.plist](../TanyaAISandboxApp/Info.plist).

Palette starter mengikuti light Figma. Jika host mempunyai mode gelap, samakan
appearance route ini dengan `.preferredColorScheme(.light)` seperti sandbox.
Composer memakai safe area/keyboard native: jangan menambahkan
`.ignoresSafeArea(.keyboard)` pada route ini.
