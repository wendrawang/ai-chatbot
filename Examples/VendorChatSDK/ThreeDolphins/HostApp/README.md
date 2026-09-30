# Alur host lengkap: AppDelegate → login → TanyaAI → deeplink

Contoh ini memakai SwiftUI dengan AppDelegate melalui
`UIApplicationDelegateAdaptor`, kompatibel iOS 15. Login dan halaman rekening/
transfer adalah layar demo. SDK chat tetap memakai konfigurasi host asli.

## Pembagian tanggung jawab

| Waktu | File | Tugas |
| --- | --- | --- |
| App mulai | HostAppDelegate.swift | Baca konfigurasi, panggil setupConnection sekali |
| Login sukses | HostUserSession.swift | Buat profil nasabah dan TanyaAIHost |
| Home tampil | HostRootView.swift | Pasang modifier tanyaAIHost |
| Tombol chat ditekan | HostRootView.swift | Panggil chatHost.present() |
| Chat dibuka | ThreeDolphinsChatSessionAdapter.swift | Observer → constructConnector |
| Bubble membuka deeplink | HostUserSession.swift | Validasi URL, buka halaman host |
| Logout | HostUserSession.swift | Tutup chat, bersihkan host dan navigasi |

Setup SDK belum membuka percakapan. Koneksi baru dimulai ketika TanyaAI dibuka.
Host tidak memanggil connect/constructConnector secara manual.

## 1. Pasang file di target host

- Empat file Swift adapter/configuration/composition/mapper di folder induk.
- Lima file Swift contoh host di folder ini.
- Dependency TanyaAI dan SDK imi_dolphin_livechat_ios milik vendor.

`HostExampleApp.swift` mempunyai `@main` untuk app contoh baru. Pada aplikasi
existing, jangan menambahkan entry point kedua: pindahkan delegate adaptor,
state session, dan wiring layar ke App/Scene yang sudah ada.

```swift
@UIApplicationDelegateAdaptor(HostAppDelegate.self) private var appDelegate
@StateObject private var session = HostUserSession()
```

Jika AppDelegate sudah ada, pindahkan konfigurasi ke
`application(_:didFinishLaunchingWithOptions:)` yang existing. Pertahankan
initialization layanan host lain. Tidak perlu membuat AppDelegate kedua.

## 2. Isi konfigurasi di AppDelegate

Contoh membaca empat key Info.plist:

| Key | Isi |
| --- | --- |
| LivechatBaseURL | Base URL dari vendor untuk environment aktif |
| LivechatClientIdentifier | Client ID dari konfigurasi host |
| LivechatClientSecret | Client secret dari konfigurasi host |
| LivechatBotIdentifier | Bot ID yang dipakai |

Jika konfigurasi host sudah memiliki environment provider, gunakan provider itu
sebagai pengganti pembacaan Bundle. Jangan masukkan credential nyata dalam contoh.
Jika konfigurasi diperoleh secara async setelah login, lakukan configure setelah
hasil tersedia, sebelum membuat/membuka chat; contoh ini mengasumsikan konfigurasi
sudah tersedia saat launch.

Dalam didFinishLaunching, implementasi contoh menjalankan:

```swift
configuration.configure()
isChatConfigured = true
```

`configure()` memanggil setupConnection sesuai foto dokumentasi iOS. Jika key
belum tersedia, contoh tidak mengonfigurasi SDK dan tombol login demo dinonaktifkan.
Flag tersebut menandai konfigurasi terpasang, bukan koneksi server berhasil.

## 3. Setelah login berhasil

Panggil dari callback login sukses pada main thread, bukan dari View.body atau
setiap onAppear. Gunakan profil hasil login host:

```swift
session.loginSucceeded(
    customer: HostCustomer(
        identifier: customer.identifier,
        name: customer.name,
        email: customer.email,
        phoneNumber: customer.phoneNumber
    ),
    mapMessage: ThreeDolphinsMessageMapper.map
)
```

`customer` di snippet tersebut adalah model nasabah host. File HostRootView
menyediakan tombol login dengan HostCustomer dummy agar wiring mudah diperiksa.
Login demo bukan autentikasi sungguhan dan tidak memberikan credential SDK.

loginSucceeded membuat DolphinProfile, lalu composition dan TanyaAIHost. Host
tersimpan di HostUserSession selama user login. Closure deeplink memakai weak
capture sehingga session tidak tertahan oleh host. Login ulang untuk user lain
harus melewati logout agar profil lama tidak terbawa.

Mapper sekarang membaca DolphinMessage dari notification.object sesuai source SDK
pada foto. Cakupannya balasan teks utuh; streaming native, history, attachment dan
carousel belum ditangani lengkap. Lihat [panduan adapter](../README.md) sebelum
mengaktifkan restore history atau streaming. Update package tidak menyalin file
adapter dalam Examples ke target host secara otomatis.

## 4. Membuka TanyaAI

Pemilik app menyimpan session sebagai StateObject. Home membaca session sebagai
ObservedObject. Host yang dibuat setelah login dipasang pada root navigasi:

```swift
NavigationView {
    Button("Buka TanyaAI") {
        chatHost.present()
    }
}
.tanyaAIHost(chatHost)
```

Modifier memberi titik presentasi kepada TanyaAIHost. Tanpa modifier pada layar
yang sedang tampil, present() tidak membuka apa pun. Jangan membuat chatHost
baru di body. Factory di composition membuat adapter baru setiap chat dibuka.

Adapter mendaftarkan observer lebih dahulu, baru constructConnector(profile:).
Saat status 2 diterima, greeting Halo dikirim sekali tanpa bubble customer.
Untuk menonaktifkan greeting, hapus silentGreeting atau isi nil di composition.
Jangan menambahkan initialPrompt Halo karena itu akan tampil sebagai pesan customer.

## 5. Deeplink kembali ke host

Contoh mengizinkan dua tujuan milik host:

| URL | Halaman |
| --- | --- |
| ocbcid://mobile/accounts | Rekening |
| ocbcid://mobile/transfer | Transfer |

Alurnya:

1. User menekan action bubble.
2. TanyaAIHost memeriksa scheme/host dan menutup chat.
3. Setelah dismissal selesai, callback onDeeplink dipanggil.
4. HostUserSession.open memeriksa URL dan status login.
5. Router mengubah destination; NavigationLink membuka halaman host.

Contoh payload bubble:

```json
{
  "messageIdentifier": "actions-1",
  "actions": [
    {
      "title": "Lihat rekening",
      "action": {
        "identifier": "open-accounts",
        "deeplink": "ocbcid://mobile/accounts"
      }
    }
  ]
}
```

Gunakan nama event `actions`. Halaman tujuan contoh hanya menampilkan teks,
tidak menjalankan transaksi.

Router tidak memanggil UIApplication.shared.open untuk URL milik aplikasi sendiri.
Ia menjalankan navigasi internal. Route tidak dikenal ditolak. Contoh juga menolak
query, fragment, port, dan user info karena kedua route ini tidak memakai parameter.
Jika menambahkan parameter, parse dan validasi sesuai kontrak layar host.

Callback onDeeplink dan URL eksternal memakai router yang sama. HostExampleApp
meneruskan URL eksternal lewat onOpenURL. Daftarkan scheme ocbcid dalam URL Types
host untuk menerima URL dari luar. Callback bubble internal tidak membutuhkan
registrasi OS. Jika user belum login, contoh mengabaikan URL; tidak ada replay
tertunda yang bisa melewati autentikasi.

Untuk host UIKit existing, gunakan router host pada onDeeplink. Jika menggunakan
TanyaAIModule.makeViewController secara langsung, host wajib memfilter URL dan
menunggu dismissal completion sendiri; lihat [integrasi UIKit](../../../../docs/HOST_UIKIT.md).

## 6. Logout

```swift
session.logout()
```

Chat ditutup dahulu. Completion membersihkan destination dan chatHost sehingga
profil serta graph fitur lama dilepas; repository menutup adapter. Sesudah callback
logout aplikasi selesai, login berikutnya membuat profil dan host baru. Penghapusan
token autentikasi aplikasi tetap tanggung jawab flow logout host yang existing.

## Verifikasi

Style checker mencakup seluruh contoh. File host dan adapter diperiksa compiler
untuk iOS 15 memakai module TanyaAI/DesignKit aktual dan stub SDK vendor. Ini belum
menguji signature SDK vendor asli, server, atau login production. Gunakan SDK dan
konfigurasi environment Anda untuk pengujian end-to-end.
