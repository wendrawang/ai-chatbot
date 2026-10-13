# Rencana migrasi bertahap ke DesignKit

Mulai dari **fondasi DesignKit: Legacy, token, font, dan sizing**. Setelah fondasi
stabil, pindahkan komponen kecil dan adopsi UI Tanya AI satu bagian setiap kali.
Tidak perlu langsung mengganti seluruh screen aplikasi atau menghapus semua
ViewModel lama.

Repositori ini adalah pilot dengan data dummy. Kode design system internal tidak
tersedia di sini. Contoh struktur dan inventory di dokumen ini adalah panduan
untuk diterapkan di repositori internal; bukan klaim bahwa komponen lama sudah
dipindahkan atau diperiksa.

Panduan API saat ini: [migrasi session dan integrasi parsial](SESSION_AND_PARTIAL_MIGRATION.md).
Aturan implementasi tim: [component style](COMPONENT_STYLE.md).

## Target akhir dan batas tanggung jawab

```text
Host app
├── Login, data pengguna, navigasi dan service existing
├── Halaman dokumen, persetujuan dan PIN existing
└── Fitur Tanya AI → DesignKit

DesignKit
├── Tokens/Generated          export Figma sebagai sumber nilai dasar
├── Tokens                    ukuran/warna tambahan di luar generated
├── Theme                     mapping semantik dan resolusi tema
├── Typography                resep font dan registrasi resource
├── Foundations               sizing, warna dan akses asset
├── Atoms / Molecules / Organisms
├── Models / Support          data presentasi dan utilitas UI
└── Legacy
    ├── Components            komponen lama yang masih dipakai
    └── Compatibility         pemetaan nama/API lama ke fondasi bersama
```

`Legacy` berarti masih didukung selama migrasi, tetapi tidak dipakai untuk
komponen baru. Pertahankan nama dan initializer lama jika memungkinkan. Gunakan
nama seperti `LegacyButton` hanya jika ada bentrok nama dengan penggantinya.
Folder tidak membuat namespace Swift secara otomatis.

`Legacy/Compatibility` bukan tempat menyalin token generated, file font, atau
implementasi `sizeInArtwork` kedua. Isinya hanya pemetaan yang masih dibutuhkan
oleh pemakai lama. Jangan menambahkan folder kosong atau komponen produksi
fiktif di pilot untuk membuat struktur terlihat lengkap.

DesignKit tidak mengimpor TanyaAI, SDK chat, model akun, AppState, maupun service
transaksi. Komponen menerima data presentasi dan callback. Host/fitur menentukan
apa yang terjadi ketika callback dipanggil.

## Tahap 0 — Inventory dan titik awal

Sebelum memindahkan file, simpan versi yang sedang dipakai dan ambil screenshot
screen existing. Catat semua pemakai design system lama. Pilih satu screen kecil
sebagai percobaan; jangan langsung menjadikan perubahan fondasi sebagai migrasi
seluruh aplikasi.

Salin tabel ini untuk setiap kelompok yang akan dipindahkan:

| Item lama | Pemakai | Nilai/tanggung jawab | Sumber baru | Kompatibilitas | Gate selesai |
| --- | --- | --- | --- | --- | --- |
| Nama token spacing | Screen/komponen | Nilai dasar atau sudah scaled? | Token Figma yang sama | Alias nama lama | Ukuran tidak berubah dua kali |
| Font/body style | Screen/komponen | PostScript, weight, size, leading | Resep typography | Mapping role lama | Font dan Dynamic Type benar |
| `sizeInArtwork` | Extension/paket | Referensi, rumus, rounding | Satu extension DesignKit | Hapus deklarasi duplikat bersama update pemakai | Build dan lebar 320/375/414 |
| Komponen + ViewModel | Screen | State tampilan atau alur async? | Legacy atau pengganti | Initializer/callback lama | Screen existing tetap bekerja |
| Asset warna/gambar | Resource bundle | Nama, mode render, variasi | Satu bundle/pemilik | Akses lewat adapter jika perlu | Resource berhasil dimuat |

Inventory juga harus mencatat minimum iOS, dependency package, localization,
dan kode bisnis yang terlanjur masuk komponen. Kode bisnis tersebut tetap berada
di host/fitur; jangan ikut memindahkannya ke DesignKit hanya karena filenya berada
di folder komponen lama.

**Gate:** daftar pemakai, baseline screenshot, versi package, dan urutan migrasi
disepakati. **Rollback:** kembali ke versi awal; belum ada perilaku yang berubah.

## Tahap 1 — Jadikan fondasi sebagai satu sumber

Ini tahap pertama yang disarankan untuk main project.

### 1A. Dependency dan Legacy

1. Tambahkan DesignKit sebagai local SwiftPM package terlebih dahulu jika lebih
   mudah menyesuaikan token internal. Gunakan satu produk DesignKit pada target.
2. Tentukan arah dependency selama transisi. Jika repo design system lama masih
   dipakai, repo lama dapat bergantung pada DesignKit untuk fondasi. Jangan
   sekaligus membuat DesignKit bergantung pada repo lama; itu menjadi siklus.
3. Pindahkan komponen lama yang siap dipindah ke `Legacy/Components`, dengan API
   dan behavior existing. Pindahkan wrapper yang diperlukan ke
   `Legacy/Compatibility`, bukan ke komponen baru.
4. Pertahankan module compatibility yang tipis bila banyak screen masih mengimpor
   nama package lama. Folder Legacy sendiri tidak mempertahankan nama module
   import. Tentukan kapan import lama akan diganti, screen demi screen.
5. Tandai `deprecated` setelah penggantinya tersedia dan dipakai dengan benar.
   Jangan menghasilkan warning massal untuk komponen yang belum punya pengganti.

ViewModel lama tetap boleh hidup di Legacy. Menghapus ViewModel tanpa memindahkan
subscription, validation, request, dan ownership secara benar dapat mengubah
behavior. Refactor komponen dilakukan di tahap berikutnya, terpisah dari
pemindahan resource dan token.

### 1B. Token dan warna

- Tetapkan satu export Figma internal sebagai sumber utama. Token dummy pilot
  tidak menjadi sumber brand produksi. Perubahan export dilakukan oleh engine,
  bukan edit manual `Tokens/Generated`.
- Cari nilai yang sama sebelum membuat token tambahan. Padding/spacing memakai
  `FigmaSize` secara langsung bila tersedia, misalnya `spacing16` dan `spacing8`.
- Nama token lama yang harus tetap tersedia cukup diarahkan ke sumber baru di
  `Legacy/Compatibility`. Jangan mempertahankan salinan nilainya.
- Nama warna dasar boleh berdasarkan palette. Komponen mengambil semantic role
  bila warna harus mengikuti tema, misalnya text, surface, divider, atau accent.
- Warna khusus yang memang belum ada di export disimpan di luar generated.
  Opacity seperti `0.4` adalah nilai dimensionless; tidak memakai sizing.
- Pisahkan pemindahan token dari perubahan tampilannya. Jika nilai export baru
  berbeda dari nilai lama, catat sebagai perubahan desain yang perlu diperiksa.

### 1C. Font

1. Cocokkan nama PostScript, weight, ukuran dasar, dan line height. Dua nama file
   tidak selalu berarti dua font berbeda.
2. Simpan satu salinan resource font dan pilih satu pemilik registrasinya.
   Font package dimuat dari `Bundle.module`; tidak perlu didaftarkan lagi melalui
   `UIAppFonts` host bila pemiliknya DesignKit.
3. Panggil `DesignKitFont.registerFonts()` sekali saat bootstrap sebelum membuat
   typography branded. Jika memakai font internal lain, sesuaikan daftar resource
   dan registry internal; jangan mendaftarkan font dummy pilot sebagai brand.
4. Tangani registrasi dengan `do/catch`. Pilih fallback secara eksplisit apabila
   registrasi gagal; jangan force unwrap hasil pencarian font.
5. Map style lama ke resep `DesignKitTypography`/`Fonts` di luar generated.
   Komponen baru memakai `.designFont(.body)` dan role lain yang sesuai.

Artwork scaling dan Dynamic Type di-resolve **sekali** dari resep ukuran dasar.
Jangan mengoper `UIFont` yang sudah scaled lalu melakukan `UIFontMetrics` lagi.
Initializer `Fonts` berbasis `UIFont` lama dianggap snapshot final; migrasi ke
resep jika ingin resolusi otomatis dari nilai dasar.

### 1D. Sizing

Satu implementasi `CGFloat.sizeInArtwork` dipakai komponen baru dan Legacy.
Hapus deklarasi duplikat saat dependency diperbarui, bukan menyalin extension
yang sama ke tiap package.

Kebijakan yang ada di DesignKit saat ini:

```text
Referensi artwork: 375 × 812
Scale: min(lebar UIScreen.main / 375, 1.25)
Ukuran: round(nilai dasar Figma × scale)
```

Referensi di-hardcode di metrics di luar generated. Tidak ada artwork environment
object, root modifier, atau observer tambahan. Tinggi 812 adalah metadata
referensi; tinggi layar tidak memberi faktor scale kedua. Kebijakan berbasis
layar ini juga berlaku pada sheet/split view, sehingga perlu ditinjau sebelum
adopsi untuk layout yang lebarnya berbeda dari layar utama.

| Nilai | Cara pakai |
| --- | --- |
| Padding, gap, radius, visual icon, shadow radius/offset | Nilai dasar `.sizeInArtwork` |
| Nilai baru yang belum ada di token | Metrics berdasarkan peran, di luar generated |
| Area sentuh | `.tapTargetInArtwork`, minimum 44 point |
| Stroke positif | `.strokeInArtwork`, minimum satu physical pixel |
| Opacity, aspect ratio, `.infinity`, persen, durasi, nominal | Tidak di-scale |
| Font | Resolusi theme/typography; jangan scale font final lagi |

Visual send button 24 bukan area tap 24. Nilai minimum tap tidak boleh berubah
menjadi 4, misalnya. Jika menghitung selisih beberapa ukuran Figma, hitung dalam
unit dasar yang sama lalu scale hasilnya sekali. Hindari mencampur ukuran dasar,
ukuran final, dan minimum accessibility dalam satu pengurangan.

### 1E. Tema

Untuk satu tema, cukup inject `.theme(selectedTheme)` pada subtree yang diadopsi.
Tidak wajib `EnvironmentObject` dan tidak perlu singleton baru. Komponen membaca
nilai `@Environment(\.theme)` yang tersedia.

Jika pengguna dapat mengganti tema secara live, host dapat memiliki satu
`ThemeManager` lalu memasang `.theme(themeManager)`. Manager dimiliki root,
bukan dibuat di `body`. Host yang sudah mempunyai pemilik state tema cukup
memetakan state existing ke `Theme`; tidak perlu dua manager yang saling sync.

**Gate tahap 1:** build host tanpa duplicate type/extension/resource; font dan
warna sesuai; Legacy tetap bekerja; ukuran diuji pada 320/375/414 point, Dynamic
Type, dan container yang dipakai aplikasi. **Rollback:** revert update dependency
beserta mapping fondasinya sebagai satu perubahan; jangan mengembalikan salinan
token duplikat sementara untuk menutup error.

## Tahap 2 — Adopsi satu komponen kecil

Mulai dengan MessageComposer pada screen kosong. Pakai seluruh package DesignKit
beserta resource/dependency internalnya; jangan copy hanya satu file view lalu
mengejar error import satu per satu.

Contoh ini memakai API publik yang tersedia. Parent menyediakan copy dan aksi,
menyimpan draft, serta mengatur margin luar:

```swift
import DesignKit
import SwiftUI

struct ComposerPilotScreen: View {
    @State private var draft = ""
    let selectedTheme: Theme
    let placeholder: String
    let sendLabel: String
    let onSend: (String) -> Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            MessageComposer(
                text: $draft,
                placeholder: placeholder,
                sendLabel: sendLabel,
                onSend: {
                    if onSend(draft) { draft = "" }
                }
            )
            .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
            .padding(.vertical, FigmaSize.spacing8.sizeInArtwork)
        }
        .theme(selectedTheme)
    }
}
```

Bool di callback berarti submission diterima secara lokal oleh pemakai; bukan
delivery receipt atau bukti bot selesai menjawab. Untuk UI dummy, pemakai dapat
menambahkan draft ke fixture lalu mengembalikan `true`.

Komponen mengurus padding dalam/surface. Screen mengurus margin luar. Jangan
menaruh margin horizontal yang sama pada dua parent bertingkat. Cek satu baris,
empat baris, lebih dari empat baris, kata panjang, keyboard, dan area tap.

**Gate:** satu screen sesuai Figma dan tetap nyaman saat ukuran teks berubah.
**Rollback:** switch pemakai screen kembali ke Legacy; fondasi tahap 1 tetap
dipakai dan tidak perlu dibongkar.

## Tahap 3 — Migrasikan komponen Legacy berdasarkan peran

Pilih komponen berikutnya berdasarkan pemakai dan manfaat, bukan berdasarkan
besar folder. Komponen puluhan variasi tidak harus dipindahkan seluruhnya menjadi
satu komponen baru.

- Variasi satu peran seperti button size/style/loading masih dapat satu komponen.
- Komponen yang sekaligus menjadi form, header, receipt, dan banner melalui
  banyak flag dipecah menjadi komponen dengan tanggung jawab yang jelas.
- `let` untuk input tampilan, `@Binding` untuk nilai milik parent,
  `@State`/`@FocusState` untuk interaksi lokal, callback untuk aksi.
- ViewModel digunakan untuk workflow/async yang memang perlu dimiliki; bukan
  kewajiban setiap `View`.
- Container reusable boleh menerima content melalui `ViewBuilder`, tanpa
  menanam seluruh keputusan bisnis sebagai flag.

Pertahankan template deklarasi/naming dari `COMPONENT_STYLE.md`. Private section
seperti `header`, `content`, dan `actionButton` digunakan untuk keterbacaan.
Extract `struct View` bila reusable, memiliki state, atau membutuhkan batas
update sendiri. Computed property tidak otomatis membuat rendering lebih cepat.

**Gate per komponen:** contoh variasi valid, accessibility, screenshot, dan
behavior pemakai sudah diverifikasi. **Rollback:** adapter/pemakai kembali ke
komponen Legacy sampai pengganti diperbaiki.

## Tahap 4 — Tanya AI sesuai Figma dengan dummy

Tahap ini tidak bergantung pada Tencent maupun kontrak backend final. Simpan
dummy pada fixture/demo/test support; jangan memasukkan nama pengguna, produk,
nominal, atau jawaban dummy sebagai default produksi di komponen.

Urutan adopsi yang disarankan:

1. **Frame screen:** header back/title/menu, background, composer, safe area.
2. **Empty state:** avatar, sapaan personal, deskripsi, `Mulai dari sini`, dan
   quick action Cek Portofolio/Beli Valas/Ajukan Surat Referensi.
3. **Teks dan prompt:** bubble user, jawaban tanpa background, bullet native,
   bold/strike/color, serta link inline.
4. **Konten terstruktur:** tabel 2–3 kolom, action pill, pilihan produk,
   ringkasan NAB, ringkasan transaksi, dan daftar persetujuan dokumen.
5. **Interaksi percakapan:** status proses bot, anchor prompt, tombol latest,
   riwayat pilihan read-only, dan reset ke welcome untuk sesi baru.
6. **Bridge host:** dokumen persetujuan, PIN existing, webview internal, deeplink,
   serta hasil balik yang memperbarui state percakapan.

Jawaban disusun sebagai blok berurutan: teks → tabel → evaluasi → action,
misalnya. Jangan membatasi seluruh jawaban ke satu urutan tetap atau menambah
ViewModel pada tiap blok. Tabel maksimal tiga kolom, header dan baris berbagi
lebar kolom, nominal rata kanan, teks membungkus. Bullet memakai marker terpisah
agar baris berikutnya sejajar dengan isi; tidak membutuhkan HTML.

Link format UI:

```text
[link]https://www.google.com|Buka Google[/link]
[link]ocbcid://mobile?type=product|Lihat produk[/link]
```

Label adalah teks yang ditap. Target HTTP/HTTPS membuka webview dalam aplikasi;
deeplink diteruskan ke handler host. Jangan menyerahkan seluruh link kepada
Safari. Scheme/policy yang diizinkan ditentukan host saat integrasi.

Perilaku UX terbaru yang perlu menjadi acceptance criteria:

- Setelah send, prompt baru mendekati atas dengan sebagian jawaban sebelumnya
  masih terlihat. Urutan history tetap kronologis; jawaban tumbuh di bawah prompt.
- Scroll manual tidak ditarik kembali setiap jawaban baru. Arrow kembali ke latest
  tetap tersedia saat membaca bagian atas.
- Produk terpilih memakai centang hijau, pilihan lain abu-abu. Semua tetap
  terlihat sebagai riwayat dan tidak dapat dipilih ulang.
- Aksi titik tiga memulai sesi baru ke welcome; draft, selection, persetujuan,
  dan posisi scroll tidak terbawa dari sesi sebelumnya.
- Host membuka dokumen/PIN existing, lalu mengembalikan hasil. Kunjungan halaman
  bukan otomatis persetujuan. PIN tidak dikirim sebagai chat text, disimpan,
  atau di-log oleh DesignKit.

**Gate:** seluruh skenario fixture sesuai delapan foto, termasuk state sebelum
dan sesudah pilihan/persetujuan; history bertahan saat kembali dari halaman host.
**Rollback:** screen pilot dapat dinonaktifkan tanpa mengubah screen existing.

## Tahap 5 — Integrasi backend dan rollout

Backend dipilih setelah UI stabil. `TanyaAIChatSession` tetap menjadi batas I/O;
adapter SDK/service tinggal di host. `.tanyaAIHost(...)` dan `present()` tetap
menjadi jalur presentasi; jangan membuat model/session baru di `body`.

Sepakati provisioning sesi baru, urutan pesan, history/pagination, status delivery,
otorisasi transaksi, dan pemulihan saat aplikasi ditutup. Reset UI dummy ke
welcome tidak membuktikan backend sudah membuat sesi baru. Jangan mengaitkan
jawaban bot dengan prompt tertentu tanpa metadata backend.

Rollout per screen atau flag internal. Sebelum melepas Legacy, cari seluruh
import/nama lama, pastikan tidak ada pemakai, dan hapus compatibility beserta
resource yang memang tidak lagi dipakai. Hapus dependency lama dalam perubahan
terpisah yang dapat direview.

**Gate produksi:** real device/SDK atau service yang dipilih, Dynamic Type,
VoiceOver, Reduce Motion, keyboard, error/retry, dan buka/tutup screen berulang.
Compiler dan unit test tidak membuktikan semua jalur bebas memory leak; lengkapi
dengan pengukuran lifecycle/performa pada perangkat yang menjadi target aplikasi.

## Hal yang belum boleh dianggap final

- Asset brand, ukuran, warna, font, dan shadow yang presisi harus memakai export
  Figma internal. Foto cukup untuk mapping; bukan sumber nilai piksel presisi.
- Bubble `Confirmed & ACK (tbd)` belum ditentukan UX. Jangan menjadikannya
  kontrak transaksi atau teks produksi final.
- Copy dan tanggal contoh harus dapat diganti dari host/fixture. Format timestamp
  dipusatkan di satu constant agar mudah direvisi.
- Dokumen ini adalah urutan migrasi. Tabel, welcome, link, retained selection,
  anchor, dan bridge terbaru harus dinilai dari implementasi serta test aktual;
  daftar acceptance criteria di atas bukan laporan validasi yang sudah selesai.
