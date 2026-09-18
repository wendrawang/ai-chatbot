# Tanya AI Sandbox

Implementasi referensi fitur chat perbankan modular: SwiftPM package lokal
`Packages/TanyaAI` plus aplikasi sandbox untuk menjalankannya.

## Bentuk arsitektur

Navigasi internal fitur memakai **UIKit** (`TanyaAICoordinator` +
`TanyaAIContainerViewController` + `UINavigationController`), bukan
`NavigationStack`. Fitur tampil sebagai view controller sendiri, jadi tidak
pernah masuk ke stack navigasi host.

Backend dijangkau lewat **satu seam**: `TanyaAIChatSession` — berbentuk sesi
(connect sekali, pesan datang sendiri), diimplementasikan host di atas SDK
vendor. Paket tidak pernah meng-import vendor. Tidak ada lagi transport SSE.

Host memakai `TanyaAIHost` + modifier `.tanyaAIHost(_:)`; itu seluruh
permukaan integrasinya. Fitur **dipresentasikan, bukan di-push** — itu yang
menjauhkannya dari stack navigasi host. Geraknya saja yang meniru push, lewat
transisi kustom.

**Design system ada di paket terpisah: `Packages/DesignKit`.** Bukan target
di dalam `Packages/TanyaAI`, tapi package sendiri, supaya kelak bisa diangkat
keluar untuk fitur lain. Ketergantungannya satu arah: TanyaAI → DesignKit,
tidak pernah sebaliknya.

Karena itu **tipe payload ikut pindah ke DesignKit**. Kalau payload tetap di
`TanyaAIDomain`, DesignKit harus bergantung balik ke TanyaAI dan SwiftPM
menolak siklusnya. `TanyaAIMessageRowView` tetap di `TanyaAIPresentation`:
tugasnya memetakan view model ke komponen, jadi ia jahitannya.

Isi DesignKit disusun atomic design:

| Folder | Isi |
| --- | --- |
| `Tokens/` | `DesignKitMetrics`, `Theme`, `Colors`, `Fonts`, `ThemeEnvironment` |
| `Models/` | `ApprovalPayload`, `ChartPayload`, `Action`, `Suggestion`, dst |
| `Atoms/` | `OutlinedBackground`, `RemoteImage`, `RichText`, `Markup`, `SegmentedBarView` |
| `Molecules/` | `TextBubble`, `ImageBubble`, `SuggestionRow`, `ActionLink`, `TypingIndicatorView`, … |
| `Organisms/` | `ApprovalBubble`, `ChartBubble`, `ReceiptBubble`, `SuggestionList`, `ActionBubble`, … |

**Angka tampilan ambil dari `DesignKitMetrics`, jangan ketik langsung.**

**Tidak boleh ada kata "Tanya" di dalam DesignKit** — nama tipe, nama file,
maupun teks. Ia harus bisa dipakai fitur lain tanpa terasa pinjaman. Host
tetap menulis `TanyaAITheme`, `TanyaAIAction`, dan seterusnya lewat alias di
`Sources/TanyaAI/Public/`, jadi perpindahan tipe antar paket tidak pernah
menyentuh kode aplikasi.

## Bubble

Sebelas tipe konten plus fallback. Yang perlu diingat soal tampilannya:

- **Prompt saran ada di dalam percakapan**, sebagai baris terakhir — bukan
  strip di atas keyboard. Lingkarannya afordans, bukan state: sekali tap
  langsung terkirim.
- **Balasan memakai bubble outline**, tanpa atribusi "TANYA AI" di atasnya.
  Hanya giliran nasabah yang punya bobot warna.
- **Deeplink tampil sebagai tautan bergaris bawah**, bukan tombol terisi,
  dan **tanpa judul di atasnya** — penjelasannya dikirim sebagai pesan teks
  biasa sebelumnya. `content.actions` tidak lagi punya `title`/`detail`.
  Kedua bobot `style` tetap berwarna aksen — yang abu-abu terbaca seperti
  tombol mati padahal aksinya tersedia.
- **Ada tiga radius: 12, 16, 18.** Itu drift dari sebelum review desain,
  bukan keputusan — dinamai `Radius.bubble`/`notice`/`card` supaya kelihatan.
  Menyeragamkannya mengubah tampilan lima bubble, jadi itu keputusan desain.
- **`content.html` statis, JavaScript mati, navigasi ditolak, tanpa base
  URL.** Chart tetap `content.chart` — ia ikut tema, ikut Dynamic Type, dan
  bisa dibaca VoiceOver; tidak satu pun bertahan di dalam web view. Kirim
  `height`, atau baris tumbuh setelah fragmen dirender.
- **Choices vs suggestion: pembedanya tombol konfirmasi, bukan jumlah
  pilihan.** Suggestion sekali tap langsung kirim; choices menunggu submit.
- **Shortcut bukan protokol.** Host yang inquiry lalu mengoper daftarnya lewat
  `TanyaAIConfiguration` — sebuah nilai, bukan layanan.
- **`content.image` mengambil gambar lewat `URLSession.shared`.** Di bank ini
  keputusan, bukan detail: host yang melakukan pinning mem-pin session-nya
  sendiri, dan ini bukan session itu. Kirim `aspectRatio` — tanpa itu tinggi
  baris berubah saat gambar mendarat.

## Perintah

| Perintah | Untuk |
| --- | --- |
| `./Scripts/verify.sh` | Gate lengkap: style, lint, test paket, test UI |
| `./Scripts/check_style.sh` | Panjang file/baris + SwiftLint |
| `./Scripts/generate_project.rb` | Regenerasi `.pbxproj` |
| `./Scripts/run_sandbox.sh [--showcase\|--deeplink]` | Jalankan sandbox |

## Dokumen

| Berkas | Isi |
| --- | --- |
| `docs/BUBBLE_SCHEMA.md` | JSON tiap bubble, minimal sampai lengkap |
| `docs/HOST_INTEGRATION.md` | Enam langkah memasang fitur di host app |

## Aturan yang mengikat

- **Nama variable 3–35 karakter; semua boolean berawalan `is`.**
  Nama wajib dari protocol SDK boleh dipertahankan dengan pengecualian lokal.
- **Maksimal 50 baris fisik per method (termasuk signature dan brace).**
- **Jangan edit isi `Tokens/Generated`; ganti hanya dengan export engine.**
  Snapshot/dummy saat ini dicatat di `docs/DESIGNKIT_THEMES.md`.
- **Maksimal 250 baris per file kode, 120 karakter per baris.** Kalau kepanjangan,
  pecah lewat extension — jangan padatkan baris.
- **SwiftLint wajib; `check_style.sh` memeriksa baris method fisik dengan SwiftParser bawaan Xcode.**
- **SwiftLint dan `verify.sh` menyapu seluruh `Packages/`**, bukan satu paket
  per nama. Paket baru ikut terjaring sejak hari pertama — tapi test-nya perlu
  langkah `xcodebuild` sendiri di `verify.sh`, karena scheme paket fitur tidak
  membawa test paket dependensinya.
- **Jangan edit `.pbxproj` manual.** Tambah/hapus file sumber aplikasi lalu
  jalankan `generate_project.rb`. Script itu mengacak UUID, jadi diff-nya
  selalu besar walau tidak ada file yang berubah.
- **`TanyaAITestSupport` tidak boleh ikut ter-ship di Release** host.
- **Nilai PIN tidak boleh di-log, dipersist, atau disalin.**
- Deployment target **iOS 15**.

## Jebakan yang sudah pernah menggigit

- **`NavigationView` membuang push yang dimulai saat pop belum selesai**, tanpa
  error. Jangan menjadwalkan navigasi dengan timer; pakai sinyal selesai
  (`onDisappear`, atau completion dari `dismiss`).
- **Deeplink hand-off harus menunggu completion dismissal.** Destinasi yang
  dibuka selagi modal masih beranimasi pergi akan hilang diam-diam.
- **SwiftLint butuh Xcode penuh.** Ia memuat `sourcekitd` dari toolchain dan
  crash kalau `xcode-select` menunjuk ke Command Line Tools. Script sudah
  meng-export `DEVELOPER_DIR` sebagai penangkal.
- **`reloadData` menggambar dari atas, dan `estimatedRowHeight` menggambar
  dua kali.** Scroll ke bawah yang dijadwalkan `DispatchQueue.main.async`
  sudah terlambat satu frame, lalu sel self-sizing melapor tinggi aslinya dan
  kontennya bergeser lagi. Untuk daftar yang dimuat sekaligus (restore
  riwayat), parkir serentak di update yang sama sampai tinggi berhenti
  berubah — jangan tutupi dengan animasi.
- **`makeSession` harus mengembalikan instance baru tiap presentasi.**
  Repository mengambil alih `onEvent` dan menutup sesi saat deinit, jadi
  instance bersama akan dicabut dari presentasi berikutnya.
