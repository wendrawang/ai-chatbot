# Jawaban empat bagian dan input generik

`TanyaAIChatInputView` dari PR input empat baris telah dipindahkan menjadi
`DesignKit.MessageComposer`. Field di dalamnya memakai `GrowingTextInput`:
satu sampai empat baris tumbuh mengikuti teks, selanjutnya scroll. Warna, font,
padding, radius, dan tinggi minimum memakai theme serta properti `.sizeInArtwork` pada token DesignKit.
Tombol kirim berada di dalam kotak pada sisi kanan bawah: abu-abu ketika disabled,
accent ketika siap kirim. Caller memberi binding teks, placeholder, label aksesibilitas, dan callback.
Logic sesi/kirim tetap di TanyaAI. Update **DesignKit dan TanyaAI bersama**.

## Format jawaban kompatibilitas

UI Figma terbaru memakai blok berurutan pada event `response`; lihat
[FIGMA_CHAT_UI.md](FIGMA_CHAT_UI.md). `answer` di bawah tetap didukung bagi
integrasi lama, dengan perilaku radio read-only yang sama.

Jawaban bot tanpa outline atau background di sekeliling seluruh jawabannya.
Prompt nasabah tetap bubble accent. Satu event `answer` dapat memuat bagian berikut:

| Field opsional | Tampilan | Perilaku |
| --- | --- | --- |
| `text` | Teks/inline markup tanpa kotak | Teks dapat berdiri sendiri |
| `options` | Radio dengan outline pada setiap option | Satu tap langsung mengirim prompt |
| `image` | Kartu gambar dengan caption opsional | Rasio disediakan agar tinggi stabil sebelum download |
| `actions` | Link ber-outline dan berwarna accent | URL diteruskan ke handler deeplink host |

Bagian selalu dibaca dalam urutan teks → radio → gambar → action. Omit bagian
yang tidak dikirim bot. Semua 15 kombinasi yang tidak kosong didukung, termasuk
radio saja atau gambar saja. Tidak ada greeting maupun suggestion lokal otomatis.
Event lama tetap didukung untuk integrasi yang sudah memakai kontrak sebelumnya.

```json
{
  "messageIdentifier": "answer-1",
  "text": "Informasi apa yang ingin Anda lihat?",
  "options": [
    {"identifier": "product", "title": "Informasi produk"},
    {"identifier": "support", "title": "Hubungi dukungan"}
  ],
  "image": {
    "imageURL": "https://cdn.example.com/promo.png",
    "caption": "Bonus bunga tabungan",
    "aspectRatio": 1.6,
    "accessibilityText": "Ilustrasi bonus bunga"
  },
  "actions": [{
    "title": "Lihat produk",
    "action": {"identifier": "product", "deeplink": "ocbcid://mobile?type=product"}
  }]
}
```

`messageIdentifier` wajib dan unik per jawaban baru. `options` memiliki
`identifier`, `title`, dan `prompt` opsional. Tanpa `prompt`, teks `title` menjadi
prompt nasabah. `image.caption` boleh dihilangkan. Bentuk `actions` sama dengan
event `actions` yang sudah ada.

Saat radio dipilih, prompt menjadi pesan nasabah dan dikirim melalui sesi yang
sudah diinjeksi. **Option tetap terlihat sebagai riwayat read-only** dengan
centang hijau pada pilihan terpilih. Pesan berikutnya menonaktifkan radio lama.
Tap ganda/replay untuk identifier yang sama tidak dapat mengirim ulang atau
mengaktifkan kembali option yang sudah dipakai.
Pilihan invalid, prompt kosong, atau tap ketika request masih aktif tidak
mengkonsumsi pilihan maupun mengganti draft.

Untuk history, hanya pesan terakhir yang memiliki radio aktif. `isAnswered: true`
tetap didukung untuk status settled eksplisit. Package tidak menulis state chat
ke penyimpanan host. Kontrak Tencent terbaru memakai `TIMTextElem`/`TIMCustomElem`;
lihat [TENCENT_MESSAGE_CONTRACT.md](TENCENT_MESSAGE_CONTRACT.md) untuk payload dan setup host.

## Meneruskan dari adapter host

Ambil objek payload JSON dari envelope vendor dan teruskan dengan sesi yang sudah ada:

```swift
onEvent?(.structuredPayload(name: "answer", json: payloadData))
onEvent?(.messageCompleted(messageIdentifier: "answer-1"))
```

`payloadData` adalah `Data` berisi objek di contoh atas, bukan envelope vendor.
Event `messageStarted` dapat dikirim sebelumnya. Text delta untuk identifier
yang sama menambah teks jawaban tanpa menghapus radio/gambar/action.
Rendering dan modifier `.tanyaAIHost(host)` tidak memerlukan perubahan di Main.
Action tetap menjalankan callback `onDeeplink` yang sudah diinjeksi host.

`choices` yang tidak mengirim `allowsMultipleSelection` kini memakai radio.
Jika integrasi lama memerlukan multi-select dan tombol submit, kirim
`allowsMultipleSelection: true` secara eksplisit.

## DesignKit untuk fitur lain

`ResponseContent` adalah organism generik dan tidak meng-import domain chat.
Caller menyuplai data presentasi serta action view. Contoh dalam host SwiftUI:

```swift
ResponseContent(
    text: responseText,
    options: presentationOptions,
    image: promotionalImage,
    onSelect: handleSelection,
    actions: {
        ActionLink(title: actionTitle, onTap: handleAction)
    }
)
```

Nilai contoh berasal dari state/resource host. `presentationOptions` berisi
`SelectionOption`, `promotionalImage` berupa `ImagePayload?`. Callback hanya
melaporkan input; caller menentukan pengiriman, navigasi, dan state setelah tap.
Font dan ukuran mengikuti tema root `.theme(...)` dan properti ukuran `.sizeInArtwork` seperti
komponen DesignKit lainnya. Token generated tidak perlu diedit.

Sandbox `--answers` menampilkan keempat bagian dan dapat dipakai untuk memeriksa
radio sebelum/sesudah tap. Ini fixture eksplisit untuk demo/test, bukan startup
behavior package produksi.

Screenshot lama yang menyembunyikan radio tidak lagi menjadi acuan UX.
Sandbox `--figma` serta screenshot pada [FIGMA_CHAT_UI.md](FIGMA_CHAT_UI.md)
memakai perilaku pilihan yang tetap terlihat.

Saat pengguna scroll ke atas, tombol `ScrollToLatestButton` generik muncul di
bawah area percakapan. Tap kembali ke pesan terbaru dan mengaktifkan auto-follow.
Balasan baru tidak memaksa posisi baca pengguna yang sedang berada di atas.
Bukti screenshot ada di [DESIGNKIT_VALIDATION.md](DESIGNKIT_VALIDATION.md).
