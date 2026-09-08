# Sendbird sebagai transport Tanya AI

Paket ini berbicara ke backend lewat satu seam saja: `TanyaAIChatSession` —
connect sekali, lalu pesan datang sendiri. Bentuk itu cocok dengan Sendbird
apa adanya: balasan bot, balasan agent, update antrean, dan reconnect semuanya
punya tempat.

Adapter di bawah ini seluruh terjemahannya. Di atasnya, bubble bertipe, PIN
sheet, dan hand-off deeplink tidak tahu Sendbird itu ada.

## Kapan memanggil apa

Ini pertanyaan yang paling sering salah dijawab.

| Panggilan Sendbird | Tempatnya | Alasan |
| --- | --- | --- |
| `SendbirdChat.initialize(params:)` | `didFinishLaunchingWithOptions`, sekali per proses | Konfigurasi lokal, tanpa jaringan. Menundanya sampai chat dibuka hanya menambah latensi. |
| `SendbirdChat.connect(userId:)` | Saat login | Round-trip jaringan + auth. Koneksinya app-wide — push dan presence ikut di situ, bukan milik satu layar. |
| `GroupChannel.createChannel` / `getChannel` | `TanyaAIChatSession.connect()` | Ini satu-satunya langkah yang benar-benar per-sesi. |
| `channel.sendUserMessage` | `TanyaAIChatSession.send(...)` | |
| `channel(_:didReceive:)` | dipetakan ke `onEvent(...)` | |
| `SendbirdChat.disconnect` | **Logout saja** | |

### Jebakan yang paling mahal

Jangan panggil `SendbirdChat.disconnect()` di dalam
`TanyaAIChatSession.disconnect()`. Itu memutus koneksi **seluruh aplikasi** —
menutup chat akan mematikan push notification dan presence. `disconnect()`
milik sesi hanya melepas channel delegate.

## Chat baru vs meneruskan chat lama

`init(botUserId:channelURL:)` menerima `channelURL` opsional:

- **nil** — percakapan baru, `createChannel`.
- **ada isinya** — meneruskan, `getChannel(url:)`.

Host yang memutuskan. Membuka dari layar History berarti meneruskan; membuka
dari entry point utama berarti baru. Adapter melaporkan channel yang dipakai
lewat `onChannelReady`, supaya host bisa menyimpannya.

Kalau channel tersimpan itu sudah tidak ada, adapter jatuh ke percakapan baru
alih-alih membuat nasabah buntu.

## Yang harus dikerjakan tim bot, bukan iOS

Bubble bertipe (approval, chart, actions) **hanya muncul kalau bot
mengirimkannya**. Bot harus menaruh JSON skema paket ini ke pesan Sendbird:

- `customType` = nama event, misalnya `content.approval` atau `content.actions`
- `data` = objek `data` milik event itu

Tanpa itu, semua balasan turun jadi teks biasa. Skemanya ada di
[`docs/BUBBLE_SCHEMA.md`](../../../docs/BUBBLE_SCHEMA.md).

`requestIdentifier` juga tidak dikirim: Sendbird tidak akan
mengembalikannya, jadi mengorelasikan giliran lewat itu adalah janji yang tak
bisa ditepati adapter. Paket sudah jatuh ke identifier pesan milik vendor.

## Wiring lengkap

Tiga tempat, tiga umur yang berbeda.

**1. Peluncuran aplikasi** — `AppDelegate.didFinishLaunchingWithOptions`:

```swift
SendbirdChat.initialize(
    params: InitParams(
        applicationId: AppConfig.sendbirdApplicationId,
        isLocalCachingEnabled: true,
        logLevel: .error,
        appVersion: Bundle.main.appVersion
    )
)
```

**2. Setelah login** — di tempat sesi nasabah dibuat, bukan di layar chat:

```swift
SendbirdChat.connect(userId: session.sendbirdUserId) { user, error in
    guard error == nil else { return }   // tampilkan sesuai kebijakan Anda
    // Push token didaftarkan di sini juga, kalau app memakainya.
}
```

Dan di logout, satu-satunya tempat `SendbirdChat.disconnect` boleh dipanggil:

```swift
SendbirdChat.disconnect { session.clear() }
```

**3. Saat chat dibuka** — tidak ada yang Anda panggil. Composition membuat
adapter baru per presentasi, dan paket yang memanggil `connect()` (malas, saat
pesan pertama dikirim) serta `disconnect()` (saat graph dilepas).

Ketiganya sudah jadi kode di folder ini:

| File | Isinya |
| --- | --- |
| `SendbirdAppLifecycle.swift` | `initialize` saat launch, `connect` saat login, `disconnect` **hanya** saat logout |
| `SendbirdTanyaAIComposition.swift` | composition root: adapter baru tiap presentasi, ingat `channelURL` terakhir |
| `SendbirdChatSessionAdapter.swift` | terjemahan Sendbird ⇄ `TanyaAIChatSessionEvent` |

Yang tersisa untuk Anda tulis sendiri tidak ada hubungannya dengan Sendbird,
dan contohnya ada di [`../../HostIntegration`](../../HostIntegration):

- `HostTanyaAITheme` — memetakan design token Anda ke `UIColor`/`UIFont`.
- `HostTanyaAIAuthorizationService` — **opsional**. Hanya perlu kalau ada
  konfirmasi yang diselesaikan di dalam chat, yaitu approval tanpa `handoff`.
  Kalau semua konfirmasi membuka flow existing lewat deeplink, lewati saja.

Merakitnya, di tempat sesi login hidup:

```swift
let composition = SendbirdTanyaAIComposition(
    botUserId: AppConfig.tanyaAIBotUserId,
    deeplinkScheme: "ocbcid",
    deeplinkHost: "mobile"
)
let tanyaAI = composition.makeHost(theme: .host) { url in
    DeeplinkManager.instance.openUrlScheme(url)
}
```

Lalu satu modifier di layar titik masuknya:

```swift
NavigationView { ... }.tanyaAIHost(tanyaAI)
Button("Tanya AI") { tanyaAI.present() }
```

`makeSession` adalah *factory*, bukan satu instance tetap. Itu disengaja: satu
adapter untuk satu presentasi. Kalau dipakai ulang, `deinit` graph lama
menghapus `onEvent` yang baru saja dipasang graph baru — chat kedua terbuka
normal lalu tidak pernah menjawab.

## Status verifikasi

Jujur soal ini, karena isinya beda-beda. Diverifikasi dengan membaca
[sendbird-chat-sample-ios](https://github.com/sendbird/sendbird-chat-sample-ios)
langsung, bukan dari ingatan.

**Terverifikasi jalan** — jalur `TanyaAIChatSession` itu sendiri. Jalankan
`./Scripts/run_sandbox.sh --vendor-session`: chat digerakkan
`MockTanyaAIChatSession`, dan `structuredPayload` tetap menghasilkan action
card bertipe.

**Cocok dengan sampel Sendbird:**

| API | Di sampel |
| --- | --- |
| `SendbirdChat.initialize(params: InitParams(...))` | `EnvironmentUseCase` |
| `SendbirdChat.connect(userId:)` / `.disconnect` | `UserConnectionUseCase` |
| `SendbirdChat.addChannelDelegate(_:identifier:)` | `OpenChannelMessageListUseCase` |
| `removeChannelDelegate(forIdentifier:)` | idem |
| `SendbirdChat.getCurrentUser()` | `UserConnectionUseCase` |
| `GroupChannel.createChannel(params:)` | `CreateGroupChannelUseCase` |
| `channel.sendUserMessage(_:completionHandler:)` | `GroupChannelUserMessageUseCase` |
| `channel(_ sender: BaseChannel, didReceive: BaseMessage)` | `OpenChannelMessageListUseCase` |
| `channelDidUpdateTypingStatus(_:)` + `getTypingUsers()` | `GroupChannelTypingIndicatorUseCase` |
| `message.data` (String, non-optional) | `StructuredDataMessageCell` |
| `message.customType` (String?) | `CategorizeUserMessageCell` |

**Masih perlu Anda cek di header SDK versi Anda** - tidak ada di sampel:

- `params.userIds` saat membuat channel. Sampel hanya memakai
  `params.addUsers([User])`, dan adapter ini hanya punya id, bukan objek
  `User`. Satu baris, sudah ditandai di kode.
- `GroupChannel.getChannel(url:)` untuk meneruskan percakapan lama. Jalur
  percakapan baru tidak menyentuhnya.

**Catatan penting soal delegate.** Sampel menerima pesan masuk di group
channel lewat `MessageCollection`, bukan lewat channel delegate; jalur
`channel(_:didReceive:)` hanya ditunjukkan untuk open channel, dan di sana
konformansinya ditulis `BaseChannelDelegate, OpenChannelDelegate` - keduanya.
Karena itu adapter ini juga menyatakan **dua** protokol. Kalau hanya
`GroupChannelDelegate` dan ternyata ia tidak mewarisi `BaseChannelDelegate` di
versi SDK Anda, pesan masuk tidak pernah sampai dan chat mati tanpa error.

`MessageCollection` sengaja tidak dipakai: ia memutar ulang riwayat dari cache
lokal, sementara daftar pesan sudah dipegang paket. Dua sumber kebenaran akan
menggandakan bubble.
