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
permukaan integrasinya.

## Perintah

| Perintah | Untuk |
| --- | --- |
| `./Scripts/verify.sh` | Gate lengkap: style, lint, test paket, test UI |
| `./Scripts/check_style.sh` | Panjang file/baris + SwiftLint |
| `./Scripts/generate_project.rb` | Regenerasi `.pbxproj` |
| `./Scripts/run_sandbox.sh [--showcase\|--deeplink]` | Jalankan sandbox |

## Aturan yang mengikat

- **Maksimal 250 baris per file, 120 karakter per baris.** Kalau kepanjangan,
  pecah lewat extension — jangan padatkan baris.
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
- **`makeSession` harus mengembalikan instance baru tiap presentasi.**
  Repository mengambil alih `onEvent` dan menutup sesi saat deinit, jadi
  instance bersama akan dicabut dari presentasi berikutnya.
