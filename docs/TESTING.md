# Menjalankan tes

| Jenis | Lokasi | Dijalankan dari |
| --- | --- | --- |
| Unit test package | `Packages/<Package>/Tests/<Package>Tests` | Scheme `TanyaAI` / `DesignKit` |
| Tes yang butuh window/scene (piksel, navigasi host) | `TanyaAISandboxTests` | Scheme `TanyaAISandbox` |
| UI test | `TanyaAISandboxUITests` | Scheme `TanyaAISandbox` |

Swift Package tidak bisa memiliki target UI test, karena XCUITest membutuhkan aplikasi
host. UI test dan tes yang membutuhkan scene sungguhan berada di sandbox (atau di target
UITests aplikasi host). `swift test` tidak dipakai: package ini hanya untuk iOS dan
memakai UIKit, jadi tes harus berjalan di simulator iOS.

## Kenapa tombol Test bisa nonaktif

Scheme package yang dibuat otomatis oleh Xcode di dalam project atau workspace aplikasi
tidak memiliki aksi Test. Target tes package lokal juga tidak bisa ditambahkan ke scheme
aplikasi (Xcode menolak dengan pesan "isn't a member of the specified test plan or scheme").

Karena itu setiap package menyimpan shared scheme di
`.swiftpm/xcode/xcshareddata/xcschemes/<Package>.xcscheme` yang sudah berisi target tesnya.
Salin folder `.swiftpm/xcode/xcshareddata` bersama package ketika memindahkannya ke repo lain.

## Dari Xcode

**Package dibuka sendiri:** File → Open → `Packages/TanyaAI/Package.swift`, pilih scheme
`TanyaAI` dan simulator, lalu ⌘U. Tutup dulu window lain yang memakai package yang sama.

**Di dalam workspace aplikasi (mis. `Byon.xcworkspace`):**

1. Klik kanan area kosong di Project Navigator (di luar project aplikasi dan Pods), pilih
   **Add Files to "<Workspace>"…**, lalu pilih folder `Packages/TanyaAI` (dan
   `Packages/DesignKit` bila perlu). Folder harus berada di tingkat workspace, sejajar
   dengan project aplikasi.
2. Pilih scheme `TanyaAI` dari dropdown dan sebuah simulator, lalu ⌘U.

Aplikasi tetap memakai package yang sama; perubahan di folder itu langsung terlihat.

## Dari terminal

Semua pemeriksaan sebelum review (lint, guard token, tes package, tes sandbox, UI test):

```sh
./Scripts/verify.sh
```

Satu package, satu kelas, atau satu fungsi tes:

```sh
cd Packages/TanyaAI
xcodebuild test -scheme TanyaAI -destination "$(python3 ../../Scripts/simulator_destination.py)" \
  -skipPackagePluginValidation -only-testing:TanyaAITests/ChatViewModelTests
```

`-skipPackagePluginValidation` menggantikan klik "Trust & Enable" untuk plugin R.swift.
Bila muncul error accessor R.swift yang tidak ada (mis. `has no member 'chatRetry'`) padahal
string sudah ada, bersihkan build (⇧⌘K) atau DerivedData lalu jalankan ulang.
