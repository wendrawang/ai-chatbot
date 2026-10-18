# Tahap 2 — shared header dan scroll

Mulai setelah composer tahap 1 stabil. Implementasikan potongan berikut satu per
satu; tidak perlu menyalin seluruh flow chat lama.

```text
DesignKit/Sources/DesignKit/
├── Components/ScreenHeader/ScreenHeader.swift
├── Components/ScreenContainer/ScreenContainer.swift
├── Extensions/View+ScrollBoundary.swift
├── Tokens/CustomSizes.swift              # Header: tinggi dan jumlah baris
└── Resources/Assets.xcassets/            # back/more/send dummy; R.swift generated

TanyaAI/Sources/TanyaAI/
├── Chat/ChatScreen.swift                 # content/menu/composer; layout dari container
├── Chat/ChatElementIdentifier.swift      # technical identifier, bukan pemetaan copy
├── Resources/{en,id,zh-Hans}.lproj/
└── Host/                                # present/dismiss existing

TanyaAISandboxApp/HeaderDemoContent.swift # fixture scroll, bukan UI produksi
```

1. Tambahkan tinggi header ke `CustomSizes.Header` dan batas baris judul ke
   `CustomTextLines.headerTitle`. Tinggi awal 56 pada artwork
   375; ukuran final dapat disesuaikan setelah nilai Figma tersedia. Judul memakai
   Fira Sans SemiBold, role `typographySizeDisplayNormal16`, hanya artwork scaling.
   Spacing memakai `spacingMedium/Large`; generated token tetap sumber tunggal.
2. Buat `ScreenHeader`: slot kiri/kanan sama besar supaya judul tetap di tengah,
   termasuk ketika trailing kosong. Ukuran back dan trailing mengikuti token icon
   dengan `.scaledToArtwork`, tanpa batas minimum SDK. Label dan action datang
   dari caller; tidak ada copy TanyaAI di sini.
   Trailing slot untuk satu action; caller memberi label/tap target yang sesuai.
3. Surface biasa opaque. Saat `isScrolled`, gunakan `.ultraThinMaterial` dan
   separator token outline di bawah. Jika Reduce Transparency aktif, pertahankan
   separator dengan surface opaque. Tidak ada blur pada teks/judul/icon sendiri.
4. Buat `ScreenContainer` untuk menyusun header sebagai overlay di atas ScrollView. Padding
   awal konten adalah tinggi header ditambah `spacingLarge`, jadi konten tidak
   tertutup saat posisi teratas. Konten dapat bergerak di belakang material ketika
   digulir. Header tidak menggambar status bar palsu; safe area tetap milik iOS.
5. `.onScrollBoundaryChange` memakai GeometryReader di background root konten.
   Callback memberi nilai awal, lalu `.onChange` mengamati Boolean ketika offset
   melewati toleransi. Tidak diperlukan PreferenceKey bersama antar observer.
   Container hanya menyimpan `isScrolled`, bukan offset setiap pixel. Kembali ke
   atas mengembalikan surface awal. ID area scroll adalah UUID lokal yang disimpan
   dengan `@State`, sehingga nilainya tetap saat parent merender ulang.
6. Pertahankan composer dan `.tanyaAIHost` existing. Header tidak mengubah font 14,
   batas empat baris, keyboard, callback kirim, atau navigation stack host.
   `TanyaAIHost` menampilkan `ChatScreen` langsung. Hapus file `HostedChatScreen`
   dari salinan lama; jangan ikut memigrasikan NavigationView/toolbar wrapper itu.

`ScreenContainer` adalah reusable layout dengan composition, tanpa inheritance,
ViewModel, AnyView, atau navigation stack baru. `ChatScreen` cukup memberi judul,
back callback, content, menu sebagai trailing dan composer sebagai footer. Header,
inset dan scroll state otomatis ditangani container. Host tetap memiliki navigasi.
`ScreenHeader` tetap tersedia terpisah jika screen mempunyai List/scroll owner sendiri.

Contoh screen biasa tanpa trailing atau footer:

```swift
ScreenContainer(title: title, backLabel: backLabel, onBack: onBack) {
    FormContent()
}
```

Contoh dengan action kanan dan footer tetap:

```swift
ScreenContainer(title: title, backLabel: backLabel, onBack: onBack) {
    FormContent()
} trailing: {
    MenuAction()
} footer: {
    SubmitAction()
}
```

Judul/label berasal dari localization fitur. Contoh view di atas milik screen;
footer mengatur margin luarnya sendiri. Container memberi margin horizontal 16
dan inset header sekali untuk seluruh konten, termasuk beberapa child builder.
Jangan membungkus screen dengan NavigationView baru untuk menggunakan container.

Deteksi boundary juga bisa dipakai sendiri pada scroll view lain:

```swift
@State private var scrollSpaceID = UUID()
@State private var isScrolled = false

// Di body:
ScrollView {
    FormContent()
        .onScrollBoundaryChange(in: scrollSpaceID) { isScrolled = $0 }
}
.coordinateSpace(name: scrollSpaceID)
```

Pasang modifier pada satu root konten, setelah padding, bukan pada ScrollView
yang diam. Untuk beberapa child, bungkus dalam VStack/LazyVStack terlebih dulu.
Setiap ScrollView memakai ID lokal masing-masing. ID hanya menjadi nama area
untuk mengukur posisi konten relatif ke ScrollView yang tepat. Simpan UUID pada
`@State`; jangan membuat `UUID()` baru pada body. Tidak diperlukan `@Namespace`
untuk kebutuhan ini. Threshold default adalah
`LayoutTolerance.measurement`; parameter threshold opsional memakai point
aktual. Observer tidak menambah ukuran atau menangkap sentuhan.

Reusability ini mengikuti [composition SwiftUI](https://developer.apple.com/videos/play/meet-with-apple/269/).
Observer memakai [onChange(of:perform:)](https://developer.apple.com/documentation/swiftui/view/onchange(of:perform:))
agar tetap cocok dengan minimum iOS 15. Satu GeometryReader tetap membaca geometri
saat scroll; yang dibatasi adalah callback dan state update, bukan klaim bahwa
semua layout/renderer berhenti bekerja. Tes menghitung transisi callback dan
isolasi nested scroll; pengukuran FPS/Instruments terpisah.

## Menu dan demo

Titik tiga membuka menu “Percakapan baru” dalam English/Indonesia/简体中文.
`onNewConversation` hanya mengirim aksi ke host. Tanpa handler, item disabled;
belum ada reset draft atau flow sesi/welcome pada tahap ini.

Jalankan `Scripts/run_sandbox.sh --language id --header-demo`, lalu buka feature.
Mode ini memberi paragraf dummy yang cukup panjang untuk mencapai akhir, kembali
ke atas, dan melihat teks di belakang header. Tanpa flag, area chat tetap kosong.
Asset back/more/send masih PDF vector sementara, dengan TODO di xcassets.
Localization dan nama asset dibaca melalui R.swift generated; lihat
[pola view dan resource](VIEW_TEMPLATE.md).

## Checkpoint sebelum lanjut

- Judul di tengah; ukuran action kiri/kanan mengikuti token desain.
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
