# Vendor chat SDK sebagai transport

Dipakai ketika percakapan dijalankan oleh SDK live chat vendor (mis. 3Dolphins
Live Chat SDK untuk Swift), tetapi tampilan chat tetap milik aplikasi Anda:
bubble bertipe, kartu approval, PIN sheet, dan hand-off deeplink tidak berubah.

## Yang berubah dan yang tidak

| Lapisan | Berubah? |
| --- | --- |
| `TanyaAIPresentation` (semua bubble & layar) | Tidak |
| `TanyaAI` (router, PIN sheet, hand-off) | Tidak |
| Repository | Dipilih otomatis: `TanyaAISessionRepository` saat sesi vendor diinjeksi |
| Transport | `TanyaAIStreamingTransport` (SSE) **atau** `TanyaAIChatSession` (vendor) |
| Adapter vendor | Baru - satu file di aplikasi Anda, contohnya di folder ini |

Cara memasangnya cuma berbeda satu baris di composition root:

```swift
let dependencies = TanyaAIDependencies(
    chatSession: VendorChatSessionAdapter(
        client: DolphinLiveChatClient(...),
        userToken: session.token
    ),
    authorizationService: AppTanyaAIAuthorization(),
    theme: .app
)
```

## Isi file

`DolphinChatSessionAdapter.swift` sudah memakai API asli SDK: `Connector`,
`DolphinProfile`, `DolphinMessage`, `setupConnection(baseUrl:clientId:clientSecrect:)`,
`enableGetQueue(isEnable:)`, `constructConnector(profile:)`,
`onSendMessage(messages:dataUser:)`, dan empat notifikasi
`com.connector.*`. `DolphinChatSessionSupport.swift` berisi `Configuration`
dan `DolphinMessageMapper`.

Pemasangannya:

```swift
let adapter = DolphinChatSessionAdapter(
    connector: connector,
    profile: dolphinProfile,
    configuration: .init(
        baseUrl: baseUrl,
        clientId: clientId,
        clientSecrect: clientSecrect,
        dataUser: sample
    ),
    mapper: DolphinMessageMapper(
        identifier: { $0.messageId ?? UUID().uuidString },
        text: { $0.message },
        payload: { $0.payload as? [String: Any] }
    )
)

let dependencies = TanyaAIDependencies(
    chatSession: adapter,
    authorizationService: AppTanyaAIAuthorization(),
    theme: .app
)
```

## Dua hal yang harus Anda cek di header framework

Dokumentasi publik SDK menyebut tipenya tapi tidak field-nya, jadi dua titik
ini sengaja dibuat terbuka dan tidak saya tebak:

| Titik | Cara memastikan |
| --- | --- |
| `DolphinMessageMapper` | Buka `DolphinMessage` di Xcode (Cmd-klik), isi tiga closure: id, teks, payload |
| `isConnected:` | Nilai `Int` mana dari `com.connector.connectionStatus` yang berarti tersambung. Default menganggap `1` |

Selain itu: dokumentasi tidak menyebutkan pemanggilan teardown. `disconnect()`
saat ini hanya melepas observer — kalau header punya fungsi penutup koneksi,
panggil di situ.

## Kontrak dengan tim bot

Agar kartu bertipe tetap hidup, bot mengirim JSON yang sama seperti pada SSE,
dibungkus amplop dua kunci lewat payload kaya milik vendor:

```json
{ "event": "content.actions", "data": { "...": "..." } }
```

`data` diteruskan apa adanya ke paket - jangan dimodelkan ulang di adapter.
Skema tiap `event` ada di [`docs/BUBBLE_SCHEMA.md`](../../docs/BUBBLE_SCHEMA.md).

Untuk hand-off yang didorong kanal (bukan tombol di kartu), kirim payload
berisi `deeplink`; adapter mengubahnya jadi `hostAction`, dan paket
meneruskannya ke handler `onAction` yang sama dengan tombol kartu. Jadi apa pun
sumber aksinya, aplikasi Anda hanya punya satu pintu keluar.

## Menguji tanpa SDK

`MockTanyaAIChatSession` di `TanyaAITestSupport` menggantikan SDK vendor:

```swift
TanyaAIDependencies(
    chatSession: MockTanyaAIChatSession.demo(
        deeplink: "ocbcid://mobile?type=transfer"
    ),
    authorizationService: MockTanyaAIAuthorizationService(),
    theme: .sandbox
)
```

`.demo(deeplink:)` mengirim typing, teks, dan kartu aksi berisi deeplink Anda.
`.handoffOnly(deeplink:)` mengirim hand-off dari kanal tanpa kartu. Di sandbox,
jalankan `./Scripts/run_sandbox.sh --vendor-session` untuk melihat keduanya.

## Yang perlu diperhatikan saat memakai SDK vendor

- **Sesi hidup lebih lama dari satu giliran.** Pesan bisa datang tanpa diminta
  (agen membalas sendiri). Paket meneruskannya lewat observer terpisah, jadi
  tidak akan tertukar dengan giliran yang sedang berjalan.
- **SDK ini mengirim pesan utuh, bukan token.** Jadi satu pesan masuk = satu
  balasan selesai, dan giliran ditutup di situ. Tidak perlu menyepakati
  penanda "pesan terakhir" dengan tim bot.
- **Notifikasi bisa datang dari thread mana pun.** Tidak masalah: ViewModel di
  paket sudah hop ke main queue sendiri.
- **`NotificationCenter` itu global.** Kalau ada dua layar memakai `Connector`
  sekaligus, keduanya menerima notifikasi yang sama. Adapter ini melepas
  observer di `disconnect()` dan `deinit`, jadi pastikan fitur ditutup rapi.
- **Reconnect adalah keadaan normal**, bukan error. Kirim `disconnected(nil)`
  untuk penutupan yang wajar dan simpan error hanya untuk yang tidak wajar.
- **PIN dan otorisasi tidak lewat kanal vendor.** Tetap lewat
  `TanyaAIAuthorizationService` milik Anda.
