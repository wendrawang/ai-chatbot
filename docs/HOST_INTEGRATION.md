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

Jika host memanggil `dismiss` lagi saat feature sedang menutup (misalnya user
menekan back lalu deeplink masuk), completion itu menunggu dismissal yang sedang
berjalan, tidak dibuang. Hal yang sama berlaku saat swipe-back dibatalkan: feature
ditutup ulang lalu semua completion dijalankan berurutan.

`present()` mengembalikan `true` bila feature dibuka. Hasilnya `false` saat feature
sudah terbuka, root belum terpasang/tidak terlihat, atau host sedang menampilkan
modal lain; panggil dari entry point saat root sudah terlihat. Hasil ini boleh
diabaikan bila host tidak memerlukannya.

## Root dengan prelogin dan main

Pasang `.tanyaAIHost(host)` pada root **main**, bukan root aplikasi. Saat main
diganti prelogin (logout, session timeout), anchor ikut hilang dan feature ditutup
tanpa animasi, sehingga prelogin tidak tertutup Tanya AI:

```swift
struct AppRoot: View {
    @ObservedObject var session: AppSession

    var body: some View {
        if session.isLoggedIn {
            MainRoot()
                .tanyaAIHost(session.tanyaAI)   // milik session main
        } else {
            PreloginRoot()
        }
    }
}
```

Ini bekerja walaupun perubahan terjadi saat feature sedang terbuka: presentasi
memakai `.overFullScreen`, view host tetap di window (disembunyikan, tidak
di-render dan tidak terbaca VoiceOver), sehingga SwiftUI tetap memproses
perubahan root. Host UIKit yang mengganti `window.rootViewController` juga
otomatis melepas feature. Karena host tidak lagi menerima
`viewWillDisappear`/`viewDidAppear` saat feature menutupinya, analytics layar host
sebaiknya tidak bergantung pada callback tersebut.
Menutup lalu membuka kembali membuat draft lokal baru. Starter belum mempunyai
session/backend atau penyimpanan history; constructor SDK lama belum diperlukan.

## Bahasa dan appearance

Bahasa dan theme diisi host langsung pada `TanyaAIHost` (lihat bagian berikut).
Copy tersedia untuk `en`, `id`, dan `zh-Hans`, termasuk label kembali. Perubahan
langsung diterapkan, juga ketika feature sedang terbuka; draft di composer tidak
hilang. Daftarkan bahasa host pada konfigurasi localization target.
Jika host belum mendeklarasikan semua bahasa package,
`CFBundleAllowMixedLocalizations = YES` memungkinkan resource dependency ikut
dipilih ([dokumentasi Apple](https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleallowmixedlocalizations)).
Contoh konfigurasi ada pada [Info.plist](../TanyaAISandboxApp/Info.plist).

Feature starter memakai light palette Figma dan menghormati safe area keyboard.
Header SwiftUI memakai `ScreenHeader` dari DesignKit: judul di tengah, kembali,
menu titik tiga, separator dan material saat scroll. Welcome mengikuti tahap
terpisah. Motion tetap memakai animasi fullscreen lama, menghormati Reduce Motion
dan arah layout. Swipe dari tepi kiri (kanan untuk RTL) menutup feature secara
interaktif dan bisa dibatalkan; dengan Reduce Motion, swipe langsung menutup tanpa
animasi geser.

## Bahasa dari Localize_Swift dan theme dari inquiry proposition

Host mengisi dua property pada `TanyaAIHost` setiap kali nilainya berubah. Tidak
perlu modifier environment atau parameter tambahan di setiap entry point; semua
pemanggilan `present()` otomatis memakai nilai terbaru.

```swift
import DesignKit
import Localize_Swift
import TanyaAI

@MainActor
final class MainSession: ObservableObject {
    let tanyaAI = TanyaAIHost(locale: Locale(identifier: Localize.currentLanguage())) { _ in true }
    private var languageObserver: NSObjectProtocol?

    init() {
        // Localize.setCurrentLanguage(_:) mengirim notifikasi ini dari Setting > Language.
        languageObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name(LCLLanguageChangeNotification), object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.tanyaAI.locale = Locale(identifier: Localize.currentLanguage())
            }
        }
    }

    deinit {
        languageObserver.map(NotificationCenter.default.removeObserver)
    }

    // Dipanggil saat inquiry proposition berhasil.
    func didLoadProposition(_ proposition: CustomerProposition) {
        switch proposition {
        case .premier: tanyaAI.colors = PremierColorConstants()
        case .privateBanking: tanyaAI.colors = PrivateColorConstants()
        default: tanyaAI.colors = DefaultColorConstants()
        }
    }
}
```

- Kode bahasa Localize_Swift (`"id"`, `"en"`, `"zh-Hans"`) langsung dipakai sebagai
  `Locale`. Bahasa lain jatuh ke English.
- `CustomerProposition` adalah tipe milik host; pemetaannya ke palette tetap di host
  karena aturan bisnis tidak masuk DesignKit. Sebelum inquiry selesai, feature
  memakai palette default.
- Saat nilai berubah dan Tanya AI sedang terbuka, header, composer, dan konten
  langsung mengikuti tanpa membuka ulang feature.
- Observer dimiliki session main, jadi ikut dilepas saat logout. `Task { @MainActor }`
  menjaga akses `TanyaAIHost` tetap di main actor walaupun closure notifikasi tidak terisolasi.
- Area SwiftUI milik host yang ingin memakai theme yang sama dapat memasang
  `.designColors(session.tanyaAI.colors)` sendiri; theme fitur tidak bergantung pada itu.

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

Folder `Host` berisi lima file:

- `ChatHostAnchor.swift`: menghubungkan `.tanyaAIHost(host)` ke controller host yang terlihat.
- `TanyaAIHost.swift`: membuat `ChatScreen` langsung dan menangani present/dismiss.
- `TanyaAIPushTransition.swift`: mempertahankan animasi fullscreen dari samping.
- `TanyaAIPushInteraction.swift`: swipe-back interaktif dari tepi layar.
- `TanyaAIHostEnvironment.swift`: meneruskan `locale`/`colors` milik host ke feature yang terbuka.

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
