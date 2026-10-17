# Membuka Tanya AI dari host app

Integrasi tetap mengikuti pola sebelumnya: pasang `.tanyaAIHost(host)` pada root
host yang sudah terlihat, lalu panggil `host.present()` dari tombol, coordinator,
atau entry point existing. Feature tampil fullscreen dengan animasi dari samping;
navigation stack host tetap dimiliki host.

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
Contoh lengkap ada pada [StartingPointApp.swift](../TanyaAISandboxApp/StartingPointApp.swift).
Font dibaca dari `Bundle.module` DesignKit; host tidak perlu menyalin file font
atau menambahkan font package ke `UIAppFonts`.

Registrasi ini memuat tujuh face Fira Sans/Open Sans. Untuk memilih font pada
komponen, gunakan nama family/weight seperti `.firaSansRegular`,
`.firaSansSemiBold`, atau `.openSansMedium`; lihat
[katalog font](../Packages/DesignKit/Sources/DesignKit/Resources/Fonts/SOURCES.md).

## Root SwiftUI dengan NavigationView existing

```swift
import SwiftUI
import TanyaAI

@MainActor
struct HostRootView: View {
    @StateObject private var tanyaAI = TanyaAIHost { _ in true }
    let openTitle: String

    var body: some View {
        NavigationView {
            Button(action: tanyaAI.present) {
                Text(openTitle)
            }
        }
        .navigationViewStyle(.stack)
        .tanyaAIHost(tanyaAI)
    }
}
```

`openTitle` berasal dari localization host. Di aplikasi Anda, pertahankan isi
`NavigationView` existing, pasang modifier sekali pada root tersebut, dan panggil
`present()` dari action existing. Tidak perlu memasang NavigationLink, binding
sheet, atau destination ke stack host.

`@StateObject` menjaga instance host tetap sama saat SwiftUI merender ulang.
Jika AppState/session owner sudah memiliki `TanyaAIHost`, gunakan instance itu;
jangan membuat instance baru di `body`. Modifier juga menerima `TanyaAIHost?`
untuk host yang baru tersedia setelah login. Mengganti nil/host tidak mengganti
identity konten utama.

Sandbox mendemonstrasikan pola yang sama pada
[SandboxHostView.swift](../TanyaAISandboxApp/SandboxHostView.swift). Jalankan
`Scripts/run_sandbox.sh --language id` lalu tekan “Buka Tanya AI”. Tombol kembali
milik feature menutup presentasinya sendiri.

## Callback kirim dan penutupan

`TanyaAIHost(isEnabled:onNewConversation:onSend:)` menerima closure `(String) -> Bool` pada main
actor. Contoh `{ _ in true }` hanya menerima draft dan membersihkan input untuk
mencoba UI. `false` mempertahankan draft. Ganti closure dengan handler host saat
migrasi pengiriman dimulai; host boleh menerima draft ke antrean untuk proses
async. Nilai true bukan konfirmasi request network berhasil.

Host dapat menutup feature dan melanjutkan routing setelah animasinya selesai:

```swift
tanyaAI.dismiss {
    // Lanjutkan routing host dari sini setelah feature tertutup.
}
```

Permintaan present berulang saat feature sudah terbuka/ditutup diabaikan. Present
sebelum root terpasang, saat root tidak terlihat, atau ketika host mempunyai
modal lain juga diabaikan; panggil dari entry point saat root sudah terlihat.
Menutup lalu membuka kembali membuat draft lokal baru. Starter belum mempunyai
session/backend atau penyimpanan history; constructor SDK lama belum diperlukan.

## Bahasa dan appearance

Locale dibaca oleh anchor dari environment root dan diteruskan saat membuka
feature. Jika host memiliki pengaturan bahasa sendiri, pasang pada root yang
membawa anchor:

```swift
NavigationView {
    // Konten host existing.
}
.tanyaAIHost(tanyaAI)
.environment(\.locale, selectedLocale)
```

`selectedLocale` bertipe `Locale` dari pengaturan host. Copy tersedia untuk `en`,
`id`, dan `zh-Hans`, termasuk label kembali. Perubahan locale berlaku saat
presentasi berikutnya. Daftarkan bahasa host pada konfigurasi localization target.
Jika host belum mendeklarasikan semua bahasa package,
`CFBundleAllowMixedLocalizations = YES` memungkinkan resource dependency ikut
dipilih ([dokumentasi Apple](https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleallowmixedlocalizations)).
Contoh konfigurasi ada pada [Info.plist](../TanyaAISandboxApp/Info.plist).

Feature starter memakai light palette Figma dan menghormati safe area keyboard.
Header SwiftUI memakai `ScreenHeader` dari DesignKit: judul di tengah, kembali,
menu titik tiga, separator dan material saat scroll. Welcome mengikuti tahap
terpisah. Motion tetap memakai
animasi fullscreen lama, menghormati Reduce Motion dan arah layout.

## Tahap header

Pemanggilan existing `TanyaAIHost { _ in true }`, `.tanyaAIHost(host)`, dan
`host.present()` tetap berlaku. Feature sekarang memakai header SwiftUI sendiri;
tidak perlu mengatur global `UINavigationBar.appearance()` pada host.

`HostedChatScreen` lama sudah dihapus. Alur presentasi sekarang langsung:
`.tanyaAIHost(host)` → `TanyaAIHost.present()` → `UIHostingController(ChatScreen)`.
Package tidak membuat `NavigationView`, `NavigationStack`, navigation title atau
toolbar native sendiri. `NavigationView` pada contoh di atas hanya milik host
existing. Header fitur adalah `ScreenHeader` SwiftUI di dalam `ChatScreen`.
`ChatScreen` memakai `ScreenContainer` DesignKit untuk memasang header, scroll,
inset dan footer secara konsisten. Halaman lain bisa memakai container yang sama
tanpa mengulang setup header; lihat [contoh pemakaian](SHARED_HEADER.md).
UIKit pada bridge dipakai untuk present/dismiss fullscreen dan animasi samping;
tidak ada navigation stack fitur tambahan.

Folder `Host` hanya memerlukan tiga file:

- `ChatHostAnchor.swift`: menghubungkan `.tanyaAIHost(host)` ke controller host yang terlihat.
- `TanyaAIHost.swift`: membuat `ChatScreen` langsung dan menangani present/dismiss.
- `TanyaAIPushTransition.swift`: mempertahankan animasi fullscreen dari samping.

Bridge ini tetap diperlukan untuk pola presentasi existing. UI halaman dan
header tetap SwiftUI; editor multiline terukur memakai bridge UITextView di DesignKit.

Jika host sudah memiliki handler sesi baru, berikan `onNewConversation` saat
membuat `TanyaAIHost`. Item “Percakapan baru” memanggil handler itu saja; package
belum membuat sesi, membersihkan draft, atau menampilkan welcome. Closure ini
dimiliki host selama host hidup; gunakan capture lemah untuk owner/coordinator
yang juga memiliki host. Tanpa handler, item menu disabled.

Overload `host.present { ContentView() }` menerima konten SwiftUI untuk area
scroll. Konten tidak perlu mempunyai ScrollView, header, atau composer sendiri.
Closure builder dievaluasi saat presentasi dan tidak disimpan oleh host; konten
dilepas setelah dismiss. Untuk migrasi UI sekarang, sandbox memakai overload ini
hanya pada mode `--header-demo`. Mode default tetap kosong. Lihat
[panduan header](SHARED_HEADER.md).
