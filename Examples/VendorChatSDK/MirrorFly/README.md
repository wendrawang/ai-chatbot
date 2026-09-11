# MirrorFly sebagai transport Tanya AI

Alternatif Sendbird. Paket `TanyaAI` tidak berubah sama sekali — satu-satunya
yang ditulis ulang adalah adapter di folder ini, karena seluruh backend
dijangkau lewat satu seam: `TanyaAIChatSession`.

Yang harus diimplementasikan cuma empat hal: properti `onEvent`, lalu
`connect()`, `send(text:context:requestIdentifier:)`, dan `disconnect()`.

## Kapan memanggil apa

| Kapan | Panggil | Di mana |
| --- | --- | --- |
| App start | `ChatManager.initializeSDK(licenseKey:)` | `AppDelegate` |
| Login sukses | `ChatManager.registerApiService(for:)` | composition root sesi |
| Layar chat muncul | `connect()` — dipanggil paket sendiri | adapter |
| Nasabah mengetik | `send(...)` — dipanggil paket sendiri | adapter |
| Layar chat tutup | `disconnect()` — dipanggil paket sendiri | adapter |
| Logout | logout MirrorFly | composition root sesi |

Simpan `userJid` dari `flyData["userJid"]` saat registrasi. Adapter butuh itu
untuk membedakan pesan lama milik nasabah dari milik bot.

### Jebakan yang paling mahal

**`messageEventsDelegate` itu tunggal, bukan registry.** Sendbird memakai
`addChannelDelegate(_:identifier:)` sehingga banyak pendengar bisa hidup
berdampingan. MirrorFly hanya punya satu slot: begitu adapter mengisinya,
apa pun di aplikasi Anda yang sebelumnya memakainya **berhenti menerima
pesan, tanpa error**. Kalau host Anda sudah memakai delegate itu untuk badge
atau notifikasi, jangan pasang adapter ini langsung — buat satu fan-out
delegate milik aplikasi, lalu adapter mendaftar ke situ.

`disconnect()` sudah menjaga bagian sebaliknya: ia hanya melepas delegate
kalau memang miliknya sendiri, jadi menutup layar chat tidak mencabut
pendengar orang lain.

**Jangan taruh logout di `disconnect()`.** Itu koneksi aplikasi, bukan
koneksi layar chat. Menutup chat tidak boleh mematikan messaging seluruh app.

## Yang lebih sederhana dibanding Sendbird

MirrorFly mengalamatkan JID langsung — tidak ada channel yang perlu dibuat.
Jadi tiga hal di adapter Sendbird hilang di sini: tidak ada `createChannel`,
tidak ada antrian pesan yang menunggu channel terbuka, dan tidak ada
`channelURL` yang harus disimpan untuk meneruskan percakapan lama.

Riwayat juga lebih sederhana: `FlyMessenger.getMessagesOf(jid:)` membaca
penyimpanan lokal dan mengembalikan nilainya langsung, bukan lewat callback.

## Yang belum terverifikasi

Dokumentasi publik MirrorFly v3 tidak menyebut sebagian simbol yang dibutuhkan
adapter. Baris yang ditandai `CHECK:` di adapter adalah yang harus dicocokkan
dengan header pod sebelum dijalankan pertama kali:

| Yang dicari | Dipakai untuk | Status |
| --- | --- | --- |
| field metadata di `TextMessage`/`ChatMessage` | bubble bertipe + `context` | **belum terverifikasi** |
| `message.messageId` | identitas pesan | dari contoh docs |
| `message.senderJid` | siapa penulis pesan lama | **belum terverifikasi** |
| API typing status | indikator sedang mengetik | ada, nama belum terverifikasi |

Yang paling menentukan adalah **field metadata**. Tanpanya, bubble bertipe
(approval, chart, receipt, dan seterusnya) tidak bisa lewat — yang tersisa
hanya teks biasa. Kalau MirrorFly ternyata tidak punya field seperti itu,
pilihannya menaruh JSON di body pesan dan mem-parse-nya di adapter, dengan
konsekuensi payload mentah terlihat di klien lain mana pun yang membuka
percakapan yang sama.

`context` sengaja dibuang untuk sekarang, bukan ditebak tempatnya. Menebak
salah berarti data routing tampil sebagai teks chat ke nasabah.

## Typing indicator

Belum dipasang. Kontraknya sudah siap — `.typing(Bool)` — tinggal
memancarkannya dari callback typing MirrorFly setelah nama API-nya
dikonfirmasi. Tanpa itu semuanya tetap jalan; indikator hanya muncul saat
giliran nasabah sedang berlangsung, bukan saat bot mengetik di luar giliran.

## Yang harus dikerjakan tim bot, bukan iOS

Sama persis seperti Sendbird: bot menaruh JSON skema paket di metadata pesan.
Nama event dan bentuk `data`-nya ada di `docs/BUBBLE_SCHEMA.md`. Adapter
meneruskannya apa adanya — iOS tidak menerjemahkan apa pun.

## Status verifikasi

**Berkas ini belum pernah dikompilasi.** Pod MirrorFly tidak ada di repo ini,
dan folder `Examples/` memang di luar target build maupun SwiftLint. Anggap
ini titik awal yang harus dicocokkan dengan header pod, bukan kode jadi.
