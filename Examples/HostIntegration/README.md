# Memasang Tanya AI ke app existing

Seluruh integrasi ada di satu objek: `TanyaAIHost`.

```swift
// sekali, di tempat sesi login Anda hidup — bukan di dalam View
let tanyaAI = TanyaAIHost(
    theme: .sandbox,
    authorizationService: YourAuthorizationService(),
    deeplinkScheme: "ocbcid",
    deeplinkHost: "mobile",
    makeSession: { SendbirdChatSessionAdapter(botUserId: "cet-bot") },
    onDeeplink: { url in DeeplinkManager.instance.openUrlScheme(url) }
)
```

```swift
// di layar yang jadi titik masuknya
NavigationView {
    ...
}
.tanyaAIHost(tanyaAI)

Button("Tanya AI") { tanyaAI.present() }
```

Itu saja. Tidak ada presenter, bridge, atau composition root yang perlu Anda
tulis sendiri.

## Kenapa aman untuk host ber-`NavigationView`

`.tanyaAIHost(_:)` menanam satu view controller kosong berukuran nol sebagai
titik present. Fitur tampil sebagai controller-nya sendiri — **bukan**
`NavigationLink`, dan tidak pernah masuk ke stack navigasi Anda.

Konsekuensinya: navigasi internal Tanya AI tidak bisa bertabrakan dengan milik
Anda, dan `NavigationView` yang rewel di app Anda tidak bisa menyeret chat-nya.

## Urutan hand-off deeplink

Saat bubble menyerahkan deeplink:

1. `TanyaAIHost` memeriksa scheme dan host. Yang tidak cocok dibuang diam-diam
   — inilah yang mencegah sebuah balasan mengirim nasabah ke `https://…` atau
   ke aplikasi lain.
2. Fitur ditutup.
3. `onDeeplink` dipanggil **setelah** layar benar-benar bersih.

Langkah 3 memakai completion dari dismissal, bukan timer. Ini bukan detail
gaya: push yang dimulai selagi modal masih beranimasi pergi akan hilang tanpa
error sama sekali.

## Dua hal yang tetap harus Anda tulis

| File di sini | Isinya |
| --- | --- |
| `HostTanyaAIAuthorizationService.swift` | Memanggil API otorisasi PIN existing Anda |
| `HostTanyaAITheme.swift` | Memetakan design token Anda ke `TanyaAITheme` |

Plus satu adapter vendor — lihat
[`../VendorChatSDK/Sendbird`](../VendorChatSDK/Sendbird).

## Yang tidak boleh

**Jangan simpan `TanyaAIHost` di `@State`.** State ikut hilang saat SwiftUI
membuang view-nya, dan presentasi tidak boleh bergantung pada itu. Simpan di
objek yang hidup di atas view tree, seumur sesi login.

**Jangan kembalikan session yang sama dari `makeSession`.** Fitur mengambil
alih callback session dan menutupnya saat dismissal, jadi instance yang
dipakai bersama akan dicabut dari presentasi berikutnya. Selalu bikin baru.

**Jangan panggil `present()` dari `onAppear` atau `body`.** Keduanya bisa
jalan berkali-kali.
