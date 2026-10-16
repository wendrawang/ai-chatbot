# TanyaAI — prototype transfer BI FAST

Prototype iOS 15+, berbasis `main`. Chat memakai UITableView/diffable, isi flow
SwiftUI, satu bubble dari input sampai receipt. Semua service di harness adalah
mock; tidak ada socket, AI model, API banking atau transaksi nyata.

Buka `TanyaAISandbox.xcodeproj`, pilih scheme **TanyaAISandbox**. Halaman awal
menyediakan skenario dan bahasa; pilih **Mulai demo baru**. Pilih **Lanjutkan sesi
tersimpan** untuk membuka instance sesi yang sama setelah menutup chat.

```sh
./Scripts/run_sandbox.sh --chat --language id --scenario success
```

Bahasa: `id`, `en`, `zh-Hans`. Skenario: `success`, `inquiryFailure`,
`pinRejection`, `pending`, `duplicateIntent`, `lateInquiry`.

- [Aturan prototype dari Wendra](docs/TANYAAI_RULES.md)
- [Integrasi dan migrasi bertahap](docs/PROTOTYPE_MIGRATION.md)
- [Hasil verifikasi dan batasnya](docs/PROTOTYPE_VALIDATION.md)
- [Usulan penghapusan, menunggu pilihan Wendra](docs/PROPOSED_DELETIONS.md)

**Belum ada file lama yang dihapus.** Wendra akan menentukan file yang boleh
dihapus. Target aktif hanya menyertakan source prototype; kode, test, contoh,
dokumentasi dan artefak milestone sebelumnya masih berada di repository.
Dokumentasi lama bukan panduan target prototype ini.

DesignKit tetap bernama **DesignKit**, mengisi peran BankDesignSystem pada diagram
rule. `Tokens/Generated` dan tujuh file font/lisensi dipertahankan dari `main`.
`TanyaAIDomain` tidak bergantung pada UI; `TanyaAIFeature` bergantung pada domain
dan DesignKit. `Examples/TanyaAIHarness` memiliki fixture, mock, builder dan store.
Target production tidak mengimpor harness. Tidak ada target TanyaAIData aktif.

Composer tetap 14pt, maksimal empat baris, action target 44pt dan visual 24pt.
Font konten lain mendukung Dynamic Type. Rich text mendukung bold, strike, warna
semantic, bullet, `[link]URL|label[/link]` dan `[link=URL]label[/link]`.
Link diteruskan ke host; harness hanya memperlihatkan tujuannya tanpa request.

PIN menerima digit demo apa pun yang lengkap sesuai configuration; tidak ada PIN
rahasia tetap. Digit hanya hidup di input sementara, tidak masuk history atau
service request. History disimpan di memory per customer/session dan hilang
setelah restart aplikasi. Otorisasi production bukan bagian prototype ini.

Untuk verifikasi:

```sh
./Scripts/bootstrap_tools.sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer ./Scripts/verify.sh
# Tambahkan TANYA_AI_TEST_DESTINATION='platform=iOS Simulator,id=…' untuk menjalankan UI tests.
```

R.swift 7.8.0 dipasang sebagai build plugin per resource target. Setelah mengganti
key/nama resource, lakukan **Product → Clean Build Folder** sebelum build agar
accessor diperbarui; output generated tidak diedit manual. Formatter adalah
SwiftFormat 0.63.1 dengan Allman, lint memakai SwiftLint dan auditor SwiftSyntax.
