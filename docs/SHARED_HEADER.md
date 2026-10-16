# Tahap 2 — shared header dan scroll

Mulai setelah composer tahap 1 stabil. Implementasikan potongan berikut satu per
satu; tidak perlu menyalin seluruh flow chat lama.

```text
DesignKit/Sources/DesignKit/
├── Components/ScreenHeader/ScreenHeader.swift
├── Tokens/CustomSizes.swift              # Header: tinggi, jumlah baris, rotasi
└── Foundations/Assets/SystemSymbol.swift # back/more dummy + TODO

TanyaAI/Sources/TanyaAI/
├── Chat/ChatScreen.swift                 # scroll + boundary + header + composer
├── Chat/ChatCopy.swift                   # key label/menu dalam 3 bahasa
├── Resources/{en,id,zh-Hans}.lproj/
└── Host/                                # present/dismiss existing

TanyaAISandboxApp/HeaderDemoContent.swift # fixture scroll, bukan UI produksi
```

1. Tambahkan ukuran header ke `CustomSizes.Header`. Tinggi awal 56 pada artwork
   375; ukuran final dapat disesuaikan setelah nilai Figma tersedia. Judul memakai
   Fira Sans SemiBold, role `typographySizeDisplayNormal16`, hanya artwork scaling.
   Spacing memakai `spacingMedium/Large`; generated token tetap sumber tunggal.
2. Buat `ScreenHeader`: slot kiri/kanan sama besar supaya judul tetap di tengah,
   termasuk ketika trailing kosong. Back dan trailing action mempunyai tap target
   minimum 44. Label dan action datang dari caller; tidak ada copy TanyaAI di sini.
   Trailing slot untuk satu action; caller memberi label/tap target yang sesuai.
3. Surface biasa opaque. Saat `isScrolled`, gunakan `.ultraThinMaterial` dan
   separator token outline di bawah. Jika Reduce Transparency aktif, pertahankan
   separator dengan surface opaque. Tidak ada blur pada teks/judul/icon sendiri.
4. Di `ChatScreen`, letakkan header sebagai overlay di atas ScrollView. Padding
   awal konten adalah tinggi header ditambah `spacingLarge`, jadi konten tidak
   tertutup saat posisi teratas. Konten dapat bergerak di belakang material ketika
   digulir. Header tidak menggambar status bar palsu; safe area tetap milik iOS.
5. Marker awal memakai GeometryReader + PreferenceKey untuk mengirim Boolean
   ketika offset melewati toleransi. `@State` hanya menyimpan `isScrolled`, bukan
   offset setiap pixel. Kembali ke atas mengembalikan surface awal.
6. Pertahankan composer dan `.tanyaAIHost` existing. Header tidak mengubah font 14,
   batas empat baris, keyboard, callback kirim, atau navigation stack host.

`ScreenHeader` adalah view kecil tanpa ViewModel/BaseScreen. Ia bisa dipakai pada
halaman lain dengan judul, back action dan trailing yang berbeda. `ChatScreen`
menyusun komponen dan memiliki scroll state, sementara host memiliki navigasi.

## Menu dan demo

Titik tiga membuka menu “Percakapan baru” dalam English/Indonesia/简体中文.
`onNewConversation` hanya mengirim aksi ke host. Tanpa handler, item disabled;
belum ada reset draft atau flow sesi/welcome pada tahap ini.

Jalankan `Scripts/run_sandbox.sh --language id --header-demo`, lalu buka feature.
Mode ini memberi paragraf dummy yang cukup panjang untuk mencapai akhir, kembali
ke atas, dan melihat teks di belakang header. Tanpa flag, area chat tetap kosong.
Asset back/more/send masih SF Symbol sementara, dengan TODO di katalog icon.

## Checkpoint sebelum lanjut

- Judul di tengah; action kiri/kanan dapat ditekan dengan tap target minimum 44.
- Posisi awal berjarak dari header. Scroll menampilkan separator dan blur,
  kembali ke atas menghilangkan keduanya, tanpa menggeser header/composer.
- Keyboard dan input empat baris tidak mengubah posisi header. Back menutup
  feature meskipun keyboard terbuka atau konten sedang scroll.
- Label/menu tersedia dalam tiga bahasa. Judul panjang tidak melebar keluar layar.
- Tutup/buka feature tidak menambah navigation stack host; konten/draft lama dilepas.

## Tahap berikutnya, tetap bertahap

1. Susun model intent dan step untuk satu contoh BI-FAST, lalu review kontraknya.
2. Buat dummy bubble nominal, rekening tujuan, summary dan receipt. Step yang
   selesai tetap tampil sebagai history dan tidak bisa dipilih ulang.
3. Hubungkan ke logic transfer existing host; dokumen/PIN memakai halaman host.
   Backend/host tetap menentukan hasil transaksi.
4. Setelah model stabil, tambahkan repository history lokal per user/session.
   Pilih storage mengikuti standar host; Core Data SQLite dapat menjadi opsi
   untuk minimum iOS 15. PIN/secret tidak menjadi payload history.

Jangan memulai seluruh tahap tersebut sekaligus. Welcome/sesi baru dibahas saat
model sesi dimulai; belum menjadi implementasi pada PR header ini.
