# Tanya AI UI Sandbox

Referensi iOS 15 untuk UI Figma terbaru, memakai data dummy. DesignKit adalah
package terpisah yang bisa dipakai fitur lain; sesi, navigasi dan transaksi
berada di TanyaAI/host. Backend/vendor belum dipilih.

## Mulai

Buka `TanyaAISandbox.xcodeproj`, jalankan scheme `TanyaAISandbox` pada simulator.
Default menampilkan welcome dengan tiga quick action. Alur Cek Portofolio
mencakup tabel, pilihan readonly, NAB, ringkasan, dokumen dan PIN host dummy.
PIN demo menghitung jumlah digit; tidak menyimpan PIN atau menjalankan transaksi.

```sh
./Scripts/run_sandbox.sh
./Scripts/run_sandbox.sh --host
```

`--host` memeriksa presentasi terpisah dari stack navigasi aplikasi lama.
Semua mode memakai katalog respons yang sama. Mode showcase/answers/vendor
lama sudah dihapus agar migrasi mengacu ke satu desain.

## Panduan

- [Migrasi bertahap: Legacy, token, font dan sizing](docs/DESIGNKIT_PHASED_MIGRATION.md)
- [Katalog komponen generik dan cara pemakaian](docs/DESIGNKIT_COPY_AND_COMPONENTS.md)
- [Mapping Figma, rich text, tabel dan bridge host](docs/FIGMA_CHAT_UI.md)
- [Integrasi host](docs/HOST_INTEGRATION.md)
- [Mulai dari composer lalu layar chat](docs/SESSION_AND_PARTIAL_MIGRATION.md)
- [Style dan kepemilikan state](docs/COMPONENT_STYLE.md)
- [Font](docs/DESIGNKIT_FONT_USAGE.md) dan [theme](docs/DESIGNKIT_THEMES.md)
- [Hasil stress test dan screenshot](docs/FIGMA_CHAT_VALIDATION.md)

## Bentuk kode

```text
Host: navigasi, webview, dokumen, PIN, backend
  → TanyaAI: public host/modifier dan composition root
    → TanyaAIPresentation: ChatScreen, state dan adapter blok
      → DesignKit: komponen, token, theme, font dan ukuran
    → TanyaAIData: repository sesi dan decoding respons
      → TanyaAIDomain / TanyaAIContracts: pesan dan seam sesi
```

Konten pesan adalah `text`, `response` berisi blok berurutan, atau fallback
`unsupported`. Blok respons: teks/catatan, tabel maksimal tiga kolom, aksi,
pilihan, metrik, ringkasan, dokumen dan aktivitas. Tidak ada renderer HTML,
chart/portfolio/receipt lama, live agent, multi-select atau PIN internal.
Dokumen dan otorisasi memakai halaman existing host melalui `onHostFlow`.

Nama DesignKit bersifat umum, misalnya `DataTable`, `SummaryCard`, `ItemHeader`
dan `QuickActionRow`. Data presentasi generik ada di DesignKit; prompt,
reference transaksi dan aturan sesi ada di fitur. Komponen tidak membutuhkan
ViewModel masing-masing. Gunakan nilai, binding, state lokal dan callback.

## Verifikasi

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer ./Scripts/verify.sh
```

Pilih simulator dengan `TANYA_AI_TEST_DESTINATION=platform=iOS Simulator,id=<UDID>`.
Verifier menjalankan formatter guard, SwiftLint, ukuran file/method, batas
DesignKit, unit/layout/lifetime tests dan UI tests. Pengujian perangkat produksi
serta aset/font brand asli tetap dilakukan ketika integrasi host tersedia.

## Perubahan API saat merapikan katalog

Update kedua package bersama. Kontrak tampilan lama `answer`, `components`,
`choices`, kartu finansial dan aliasnya dihapus; gunakan `response.blocks`.
`authorizationService`, `onConfirmation`, `historyItems` dan `shortcuts`
dihapus. Gunakan `welcome`, `makeNewSession` dan `onHostFlow`. `.tanyaAIHost(host)`
dan `host.present()` tetap dipakai. Restorasi history sesi aktif tetap tersedia.
Contoh vendor lama dihapus; adapter backend baru cukup mengikuti
`TanyaAIChatSession` dan vocabulary saat ini. Kode sebelumnya ada di riwayat Git.

Semua data repo ini contoh. `TanyaAITestSupport` hanya untuk Debug/test,
bukan target Release host.
