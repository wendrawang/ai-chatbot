# 3Dolphins sebagai transport Tanya AI

Paket `TanyaAI` tidak berubah sama sekali. Seluruh backend masuk lewat satu
seam — `TanyaAIChatSession`, empat anggota — jadi ganti vendor berhenti di
folder ini.

## Sebelum apa pun: kredensial di dokumentasi sudah bocor

Halaman dokumentasi publik 3Dolphins memuat **client secret produksi** dan
**password admin** dalam teks terang:

| Yang terpublikasi | Di mana |
| --- | --- |
| clientId + clientSecret beta dan produksi | `ChatConfig.swift` di dokumentasi |
| `graphUsername` / `graphPassword` admin | contoh integrasi |
| `botId` default | contoh integrasi |

Siapa pun yang menemukan halaman itu memilikinya. **Jangan pakai nilai-nilai
itu.** Minta kredensial sendiri ke 3Dolphins, dan sampaikan ke mereka bahwa
yang di dokumentasi perlu dirotasi. Untuk aplikasi bank ini bukan catatan
kecil.

## Kapan memanggil apa

| Kapan | Panggil | Di mana |
| --- | --- | --- |
| App start | `Connector.shared.setupConnection(...)` | `AppDelegate` |
| Login sukses | bangun `DolphinProfile` | composition root sesi |
| Layar chat muncul | `constructConnector` — lewat `connect()` | adapter |
| Nasabah mengetik | `onSendMessage` — lewat `send(...)` | adapter |
| Layar chat tutup | `endActiveSession` — lewat `disconnect()` | adapter |

Perhatikan ejaan `clientSecrect` pada `setupConnection`. Typo itu ada di API
publik SDK-nya, jadi kode Anda harus ikut salah eja.

## Beda bentuk dari Sendbird

**Tidak ada delegate.** Pesan masuk lewat `NotificationCenter` dengan konstanta
`String` telanjang (`notificationMessage`, `notificationConnectionStatus`),
bukan `Notification.Name`. Observer harus dipasang **sebelum**
`constructConnector`: status yang datang sebelum ada yang mendengarkan hilang
begitu saja, dan tidak ada cara menanyakannya ulang.

**Status koneksi berupa angka 1–6.** Hanya 2 (Connected) yang berarti siap.
4/5 jadi `.disconnected`, 6 jadi kegagalan lampiran. 1 dan 3 sedang berjalan.

**Balasan datang bertahap.** 3Dolphins melakukan streaming token demi token —
justru lebih cocok dengan kontrak paket (`messageStarted` → `messageDelta` →
`messageCompleted`) daripada Sendbird, yang mengirim pesan utuh sehingga
adapter harus memalsukannya sebagai satu delta.

**Riwayat butuh dua panggilan** (`fetchConversations` lalu
`fetchConversationChats`), dan keduanya mengembalikan `[[String: Any]]`.

## Yang menentukan layak atau tidaknya

**3Dolphins tidak punya padanan `custom_type` + `data` milik Sendbird.**

Itu kalimat terpenting di berkas ini. Tanpa satu field yang bisa membawa JSON
bebas dan kembali lagi saat riwayat dibaca, **tidak ada satu pun bubble
bertipe yang bisa lewat** — approval, chart, receipt, gambar, deeplink,
semuanya. Yang tersisa hanya teks biasa.

Satu-satunya kandidat adalah `dataUser: AnyObject?` pada `onSendMessage` dan
`sendAttachment`. Dokumentasi tidak pernah menjelaskan gunanya, bentuknya,
apakah ia kembali ke klien, atau apakah ia muncul di `DolphinMessage` yang
masuk. Tidak ada satu contoh pun yang memakainya.

Tiga kemungkinan, dan hanya satu yang menyelamatkan fitur ini:

1. `dataUser` adalah amplop dua arah → semuanya jalan, tulis ulang
   `ThreeDolphinsChatSessionAdapter+Cards.swift` dan selesai.
2. `dataUser` hanya satu arah, atau hanya untuk data profil → kartu harus
   dibawa di dalam teks pesan. Fungsi `card(inText:)` di berkas itu sudah
   ditulis untuk jalur ini. Konsekuensinya JSON mentah terlihat di klien lain
   mana pun yang membuka percakapan yang sama, dan di dashboard vendor.
3. Tidak ada jalan sama sekali → pakai struktur bawaan 3Dolphins (carousel
   card, knowledge source box) dan petakan bubble kita ke sana. Ini berarti
   merancang ulang, bukan menyesuaikan.

Cara memastikannya: baca `Connector.swift` dan `DolphinMessage.swift` dari
pod, lalu tangkap satu frame `/app/wmessage` sungguhan.

## Yang belum terverifikasi

Ditandai `CHECK:` di kode. Berbeda dari adapter Sendbird, di sini yang belum
pasti **lebih banyak daripada yang pasti** — dokumentasi 3Dolphins
menjelaskan permukaan panggilannya, bukan datanya.

| Yang dicari | Dipakai untuk | Status |
| --- | --- | --- |
| properti `DolphinMessage` | teks, id, penulis, penanda streaming | **tidak dipublikasikan** |
| bentuk `notification.object` | membaca pesan dan status masuk | **tebakan** |
| penanda chunk terakhir | menutup giliran | **tidak dipublikasikan** |
| key respons riwayat | memetakan pesan lama | **tidak dipublikasikan** |
| `dataUser` | bubble bertipe | **tidak dipublikasikan** |

Kalau penanda chunk terakhir salah, gejalanya persis yang sudah pernah
menggigit di proyek ini: indikator mengetik berputar selamanya dan tombol
kirim tersangkut jadi Stop.

## Yang tidak ada sama sekali

- **Typing indicator.** Kontraknya siap (`.typing(Bool)`), servernya tidak
  mengirim apa-apa. Animasi tiga titik di contoh 3Dolphins murni lokal.
- **Quick reply / suggestion chips.** Tidak ada di platformnya.
- **SPM.** Hanya CocoaPods: `imi-dolphin-livechat-ios`.

## Status verifikasi

**Berkas ini belum pernah dikompilasi.** Pod 3Dolphins tidak ada di repo ini,
dan folder `Examples/` memang di luar target build maupun SwiftLint. Anggap
ini titik awal yang harus dicocokkan dengan header pod, bukan kode jadi.
