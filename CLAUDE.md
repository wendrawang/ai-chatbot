# Tanya AI Sandbox

Implementasi referensi fitur chat perbankan modular: SwiftPM package lokal
`Packages/TanyaAI` plus aplikasi sandbox untuk menjalankannya.

## Bentuk arsitektur

Navigasi internal fitur memakai **UIKit** (`TanyaAICoordinator` +
`ChatContainerViewController` + `UINavigationController`), bukan
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

Data presentasi reusable tetap di `DesignKit/Models`. Kontrak fitur chat
(approval transaction/challenge, action/deeplink, pilihan prompt, suggestion,
agent handoff) berada di `TanyaAIDomain`; view-nya di
`TanyaAIPresentation/Components/Chat`. `MessageRowView` menjahitnya.
DesignKit tidak memerlukan dependensi balik ke fitur.

Isi DesignKit disusun atomic design:

| Folder | Isi |
| --- | --- |
| `Tokens`, `Theme`, `Typography`, `Foundations` | Nilai dasar, semantic mapping, font dan artwork metrics |
| `Models` | Data presentasi chart, image, information, receipt, portfolio |
| `Atoms` | Primitive visual dan button style |
| `Molecules` | Text/image/status/information card dan chart legend |
| `Organisms` | Chart, receipt, portfolio, financial list dan HTML card |
| `Support` | Parser, image loading, WebKit dan perhitungan layout; bukan UI atom |

**Angka tampilan ambil dari `DesignKitMetrics`, lalu gunakan properti `.sizeInArtwork`.**
Referensi hardcoded 374×812, skala dari `UIScreen.main`; tidak ada artwork environment/root modifier.
Generated token selalu nilai dasar; konversi tidak mengubah token. Stroke dan area tap menggunakan
`.strokeInArtwork` / `.tapTargetInArtwork` untuk menjaga batas minimum.

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
- **Teks balasan tanpa bubble outline atau background.** Prompt nasabah tetap
  memakai accent bubble. `answer` menggabungkan teks, radio, gambar, dan action
  sebagai bagian opsional; outline hanya pada masing-masing option/kartu/link.
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
- **Radio satu tap langsung mengirim prompt, lalu option list pada jawaban itu
  hilang.** `choices` default single-select; `allowsMultipleSelection: true`
  mempertahankan kontrak multi-select + submit untuk integrasi lama.
  Radio hanya tampil pada pesan terakhir; pesan baru menghabiskan option lama.
  Teks, gambar, dan action tetap tampil setelah radio dipilih.
- **Input generik memiliki tombol kirim di dalam kotak, tumbuh sampai 4 baris lalu scroll.**
  Tombol ke pesan terbaru muncul saat pengguna menjauh dari bawah; pesan baru tidak
  menarik posisi baca pengguna.
- **Shortcut bukan protokol.** Host yang inquiry lalu mengoper daftarnya lewat
  `TanyaAIConfiguration` — sebuah nilai, bukan layanan.
- **`content.image` menggunakan `ImageLoading` yang bisa diinjeksi.** Host dapat
  memakai `ImageLoader(session: pinnedSession)` per sesi. Clear decoded cache
  saat logout; task view dibatalkan saat dilepas. Kirim `aspectRatio` agar tinggi stabil.

Panduan migrasi: `docs/DESIGNKIT_MIGRATION.md`.
Copy multilanguage dan komponen generik: `docs/DESIGNKIT_COPY_AND_COMPONENTS.md`.
Teks UI dari resource/injeksi host; jalankan `Scripts/check_design_system.py`.

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
