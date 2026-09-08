# Memasang Tanya AI ke app existing

Seluruh integrasi ada di satu objek: `TanyaAIHost`.

```swift
// sekali, di tempat sesi login Anda hidup — bukan di dalam View
let tanyaAI = TanyaAIHost(
    theme: .sandbox,
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

Kalau layar itu dibuat tanpa argumen — `MainCoordinator()` di tengah root
screen, misalnya — `TanyaAIHost` adalah `ObservableObject`, jadi bisa
di-inject lewat environment seperti state object yang sudah Anda oper:

```swift
MainCoordinator()
    .environmentObject(appState)
    .environmentObject(tanyaAI)
```

```swift
struct MainCoordinator: View {
    @EnvironmentObject var tanyaAI: TanyaAIHost
}
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

## Yang harus Anda tulis

| File di sini | Wajib? | Isinya |
| --- | --- | --- |
| `HostTanyaAITheme.swift` | ya | Memetakan design token Anda ke `TanyaAITheme` |
| `HostTanyaAIAuthorizationService.swift` | tidak | Hanya kalau chat mengotorisasi transaksi sendiri |

Plus satu adapter vendor — lihat
[`../VendorChatSDK/Sendbird`](../VendorChatSDK/Sendbird).

### Kapan `authorizationService` diperlukan

PIN sheet di dalam fitur **hanya** terbuka untuk approval yang datang **tanpa**
`handoff`. Kalau setiap konfirmasi dari bot membawa `handoff` — yaitu membuka
flow existing Anda lewat deeplink — sheet itu tidak pernah muncul dan
parameternya boleh dibiarkan nil.

Ini keputusan kontrak bot, bukan keputusan iOS. Tanyakan ke tim bot apakah ada
skenario approval yang harus diselesaikan **di dalam chat**.

Kalau nil dan approval tanpa `handoff` tetap datang, tombol Confirm tidak diam
saja: chat menolaknya dengan pesan yang terlihat, supaya tidak ada tombol mati.

## Yang tidak boleh

**Jangan simpan `TanyaAIHost` di `@State`.** State ikut hilang saat SwiftUI
membuang view-nya, dan presentasi tidak boleh bergantung pada itu. Simpan di
objek yang hidup di atas view tree, seumur sesi login.

**Jangan kembalikan session yang sama dari `makeSession`.** Fitur mengambil
alih callback session dan menutupnya saat dismissal, jadi instance yang
dipakai bersama akan dicabut dari presentasi berikutnya. Selalu bikin baru.

**Jangan panggil `present()` dari `onAppear` atau `body`.** Keduanya bisa
jalan berkali-kali.
