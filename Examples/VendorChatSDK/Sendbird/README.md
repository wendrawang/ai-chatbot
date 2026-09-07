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

## Status verifikasi

Jujur soal ini, karena isinya beda-beda:

- **Terverifikasi jalan** — jalur `TanyaAIChatSession` itu sendiri. Jalankan
  `./Scripts/run_sandbox.sh --vendor-session`: chat digerakkan
  `MockTanyaAIChatSession`, dan `structuredPayload` tetap menghasilkan action
  card bertipe.
- **Terverifikasi tipe** — konformansi adapter ini terhadap
  `TanyaAIChatSession` dan pemetaan event-nya, di-type-check terhadap stub API
  Sendbird.
- **Belum terverifikasi** — nama API Sendbird-nya sendiri, karena SDK-nya tidak
  ada di repo ini. Diambil dari
  [sendbird-chat-sample-ios](https://github.com/sendbird/sendbird-chat-sample-ios).
  Yang **tidak** saya temukan di sampel itu dan perlu Anda cek di versi SDK
  Anda: `params.addUserIds`, `message.data`, dan
  `channelDidUpdateTypingStatus`. Sisanya terbaca langsung di sana.
