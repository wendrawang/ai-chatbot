# Mocking jawaban AI di aplikasi Anda

Untuk demo, QA, dan UI test: jawaban terskrip tanpa backend, tanpa bot.

| File | Isi |
| --- | --- |
| `DemoTanyaAITransport.swift` | Transport yang memutar skrip sebagai SSE, lengkap dengan pemotongan dan pembatalan |
| `DemoTanyaAIScripts.swift` | Skripnya: teks, kartu informasi, kartu aksi berisi deeplink, konfirmasi dengan hand-off, dan satu stream yang sengaja terputus |

## Pemasangan

```swift
TanyaAIDependencies(
    streamingTransport: DemoTanyaAITransport(),
    authorizationService: MockTanyaAIAuthorizationService(),
    theme: .app
)
```

Selesai. Ketik "saldo", "transfer", atau "konfirmasi" di chat dan skrip yang
sesuai akan diputar. Rutenya ada di `DemoTanyaAIScript.reply(to:)` — tambah
kata kunci sesuai kebutuhan demo.

Ini untuk **target debug/test saja**. Ikut ke Release berarti mengirimkan
chatbot yang mengabaikan backend.

## Menambah skrip sendiri

Satu event SSE bentuknya:

```
event: content.actions
data: {"messageIdentifier":"m1-card","actions":[...]}

```

Skema tiap `content.*` — approval, receipt, chart, portfolio, financial-list,
status, actions — ada di [`docs/BUBBLE_SCHEMA.md`](../../docs/BUBBLE_SCHEMA.md).
Bentuk JSON-nya sama persis dengan yang harus diproduksi backend nanti, jadi
skrip di sini sekaligus jadi contoh kontrak untuk tim bot.

## Empat kesalahan yang gagal tanpa pesan error

**`items` wajib ada di `content.information`.** DTO-nya bukan optional, dan
kegagalan decode menghentikan **seluruh** stream, bukan cuma kartu itu. Kalau
kosong, kirim `"items": []`.

**`messageIdentifier` kartu harus beda dari `messageIdentifier` teks, dan
harus baru di tiap balasan.** Identifier yang sama menimpa bubble yang sudah
ada alih-alih menambah yang baru: teks tertimpa kartu, atau — yang paling
membingungkan — konfirmasi yang sudah dibatalkan nasabah terlihat terbuka
kembali. Skrip di sini memakai `turn` acak per balasan supaya itu tidak
terjadi.

**`response.completed` wajib dikirim.** Tanpa itu indikator mengetik tidak
pernah berhenti dan tombol kirim tetap jadi tombol stop. `neverCompletes`
di file skrip sengaja memperlihatkan kondisi ini.

**Jangan potong skrip tepat di batas event.** `chunkSize` default 24 byte
memotong di tengah baris, persis seperti jaringan sungguhan. Kalau tiap
potongan kebetulan satu event utuh, parser SSE tidak pernah teruji di sini dan
bug-nya baru muncul saat menghadapi backend asli.

## Deeplink

Deeplink ditulis di dalam skrip, di dua tempat:

- `content.actions` → tombol di kartu;
- `content.approval` dengan `handoff` → tombol Confirm menyerahkan ke host,
  dan PIN sheet in-app tidak terbuka.

Yang **membuka** deeplink tetap aplikasi Anda, lewat handler `onAction` di
`TanyaAIModule.makeView`. Kalau tombol ditekan dan tidak terjadi apa-apa,
urutan pemeriksaannya: scheme dan host lolos validasi Anda, scheme terdaftar
di `CFBundleURLTypes`, dan navigasi dijalankan setelah chat tertutup — bukan
di dalam `onAction`. Contohnya ada di
[`Examples/NavigationViewHost/Deeplink`](../NavigationViewHost/Deeplink).

## Skenario gagal

Jalur bahagia saja tidak cukup. Dua yang paling murah dicoba:

```swift
// Error banner
MockTanyaAIStreamingTransport(scenario: .failure(URLError(.notConnectedToInternet)))

// Stream terputus di tengah
DemoTanyaAIScript.neverCompletes
```
