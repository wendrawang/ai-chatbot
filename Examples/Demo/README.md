# Demo tanpa backend

Untuk melihat tampilannya sekarang, sebelum SDK vendor ada.

Bot-nya menjawab dari fixture. Semua bubble bisa dilihat, disentuh, dan
direview di aplikasi Anda sendiri dengan tema Anda sendiri. Saat SDK-nya
datang nanti, yang berubah **satu baris** — `makeSession` — dan tidak ada
bagian lain dari host yang bergeser.

## Dua cara melihatnya

### 1. Sandbox di repo ini — tanpa menyentuh aplikasi Anda

```bash
./Scripts/run_sandbox.sh --showcase
```

Catatan: script itu berakhir dengan `--console-pty`, jadi ia menempel ke
aplikasi dan tidak pernah kembali ke prompt. Itu memang gunanya — log
aplikasi muncul di terminal. Tekan Ctrl-C kalau tidak perlu.

### 2. Di aplikasi Anda — untuk melihatnya dengan tema Anda

Salin `DemoTanyaAIComposition.swift` ke target aplikasi, lalu:

```swift
struct RootScreen: View {
    @StateObject private var tanyaAI = DemoTanyaAIComposition(
        deeplinkScheme: "ocbcid"
    ).makeHost(theme: TanyaAIAppearance.theme) { url in
        print("deeplink:", url)
    }

    var body: some View {
        NavigationView {
            List {
                Button("Tanya AI") { tanyaAI.present() }
            }
        }
        .tanyaAIHost(tanyaAI)
    }
}
```

Untuk langsung membuka seluruh bubble tanpa mengetik, pakai
`makeShowcaseHost(theme:onDeeplink:)`.

## Apa yang diketik untuk memunculkan apa

Bot merespons kata kunci, bukan jawaban acak:

| Ketik yang mengandung | Muncul |
| --- | --- |
| `showcase` | semua bubble sekaligus |
| `deeplink` | tautan hand-off + approval yang menyerahkan ke layar host |
| `transfer` | konfirmasi transfer — Confirm membuka bottomsheet PIN |
| `currency` / `conversion` | konfirmasi konversi valas |
| `deposit` | konfirmasi deposito |
| `saving` | konfirmasi rencana menabung |
| `spending` | grafik pengeluaran |
| `incoming` | daftar dana masuk |
| `bill` | daftar tagihan terbayar |
| `limit` | kartu informasi |
| *selain itu* | ringkasan portofolio |

## PIN

`MockTanyaAIAuthorizationService(acceptedPIN: "123456")`.

PIN lain ditolak — dan itu justru separuh yang lebih menarik untuk dilihat,
karena menunjukkan bagaimana kegagalan otorisasi tampil di percakapan.

## Yang tidak bisa didemokan di sini

- **Typing indicator dari bot.** Kontraknya ada (`.typing(Bool)`), tapi mock
  tidak mengirimkannya di luar giliran. Yang terlihat hanya titik-tiga saat
  giliran sedang berjalan.
- **Riwayat.** Mock tidak mengirim `.history`, jadi tiap presentasi mulai dari
  sapaan. Jalur riwayatnya ada dan ada test-nya, tapi butuh backend yang
  menyimpan.
- **Streaming sungguhan.** Fixture mengirim potongan dengan jeda tetap; bot
  asli mengirimnya sesuai kecepatannya sendiri.

## Sebelum ini ikut ter-build ke Release

Berkas ini dibungkus `#if DEBUG`, dan `TanyaAITestSupport` **tidak boleh**
di-link di Release. Ia berisi jawaban karangan termasuk kartu konfirmasi:
build produksi yang bisa menggambar approval transfer palsu itu cacat, bukan
demo.
