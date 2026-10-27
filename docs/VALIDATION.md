# Validasi starter

## Tanpa R.swift — 27 Oktober 2026

CI host (fastlane gym, Xcode 26) gagal di `Validate plug-in "RswiftGenerate…Resources"`:
build tool plugin wajib di-trust per mesin dan runner non-interaktif tidak bisa. R.swift
dilepas dari DesignKit, TanyaAI dan sandbox. Copy memakai enum key (`ChatCopy`,
`SandboxCopy`) dan `String(key:bundle:locale:)`; gambar memakai `DesignImage`; fixture
memakai `SandboxFixtureFile`. Pengganti pengecekan compile R.swift: tes per bahasa bahwa
key enum sama persis dengan isi `Localizable.strings`, tes setiap `DesignImage` termuat
dan setiap imageset punya case, serta tes setiap fixture ter-bundle.

## Perbaikan dari review — 27 Oktober 2026

Empat bug direproduksi dengan test lebih dulu (`ChatRecoveryTests`, gagal sebelum diperbaiki):

1. Stream putus saat mengirim membuat composer macet di loading. Kini pesan user baru di history
   setelah reconnect dianggap pertanyaan giliran itu.
2. Replay pesan user lama membajak giliran pertanyaan berikutnya. Kini hanya pesan yang benar-benar
   baru (`merge` mengembalikan pesan yang ditambahkan) yang memajukan giliran.
3. View model tertahan sampai request awal selesai karena `await self?.establish()`. Init/history/
   config kini berjalan di `ChatSessionStart.load` tanpa memegang view model.
4. Jawaban yang dihentikan muncul lagi lewat history. Filter kini berlaku di `merge` untuk semua sumber.

`merge` menambahkan pesan baru di akhir tanpa mengurutkan ulang; pengurutan penuh hanya saat history
lama masuk. Helper hitung di `ConnectionBanner`, `NoticeLabel` dan `TanyaAITermsScreen` dipindah ke
`private extension`. UI test menyimpan screenshot `chat-sending` dan `chat-waiting`.

## Satu file satu tipe — 27 Oktober 2026

Seluruh repo dirapikan: satu tipe per file, tanpa tipe nested di luar token/`ComponentIdentifier`,
dan class hanya untuk base framework. `BaseCallback` dihapus (use case jadi struct, error service
diteruskan lewat closure ke view model yang membuat use case secara lazy), `AppState` memakai
`isLoggedIn`, `CodingKeys` diganti enum key sendiri, probe test diganti closure, dan suite window
sandbox menjadi satu `HostWindowTests` berurutan dengan extension per file. Persetujuan T&C cukup
Bool. `Scripts/check_methods.swift` kini juga menolak pelanggaran aturan tipe.

## Flow chat ICT, T&C host, dan stop — 26 Oktober 2026

`TanyaAIService` kini `start` → `history` → `config` (hanya bila history kosong) → `events`,
dengan `send` tanpa body balasan dan `cancel(messageId:)`. Pesan user tampil saat datang dari
stream; tombol kirim berganti titik bergerak (`LoadingDots`) selama menunggu pesan itu, lalu stop
selama menunggu jawaban. Greeting dan shortcut (`SuggestionChip`) tampil di percakapan kosong.
T&C ditampilkan host sekali sebelum Tanya AI; persetujuan disimpan ke BE (opsional) dan perangkat.

Dibuktikan oleh test: config hanya saat history kosong; chat tampil dari stream dan draft
dikosongkan saat itu; kirim gagal; stop mengabaikan jawaban terlambat, stop gagal tetap menunggu,
jawaban yang tiba saat stop tetap tampil; reconnect menemukan jawaban yang terlewat; shortcut hanya
di percakapan kosong; ukuran composer sama di ketiga keadaan; T&C disimpan, tidak dimuat lagi,
inquiry offline memunculkan blocker. UI test: T&C sekali lalu chat langsung, shortcut dijawab
lewat stream, stop dengan `--slow-reply`. Baris yang isinya berubah di-reload (bukan reconfigure)
karena cell hosting tidak menggambar isi baru yang menambah tinggi.

## Unit test ke Swift Testing — 26 Oktober 2026

Seluruh unit test (`DesignKitTests`, `TanyaAITests`, `TanyaAISandboxTests`) pindah dari
XCTest ke Swift Testing tanpa mengubah perilaku yang diuji. `swift-tools-version` tetap
5.7; Swift Testing ikut toolchain Xcode 16 ke atas. UI test tetap XCTest. Penantian async
memakai `waitUntil` berbasis `Task.sleep`; suite sandbox yang memakai window berada di
bawah `HostWindowTests` yang `.serialized`, dan `TanyaAIHostTests` juga `.serialized`.

Hasil: DesignKit 17 tes (warna hex tidak valid tanpa fallback kini tes sendiri), TanyaAI
4, sandbox unit 8, ditambah UI test XCTest; lint 0 pelanggaran.

## Alur chat dengan SSE persistent — 22 Oktober 2026

`TanyaAIHost(service:)` menggantikan `onSend`. Saat halaman tampil: init sesi → history →
stream SSE tetap terbuka; chat dikirim lewat `send` terpisah dan jawaban datang lewat
stream. Reconnect otomatis sekali (init ulang + history + stream), lalu status "Koneksi
terputus. Coba lagi". Daftar pesan memakai `UITableView` diffable (cell hosting SwiftUI,
fallback iOS 15), history lama dimuat saat mendekati atas tanpa menggeser posisi baca.
Sandbox memakai service dummy dari `ChatDummy.json`; `--long-history` dan `--offline`.

Dibuktikan oleh test: urutan init → history → stream; chat tampil langsung lalu
terkonfirmasi dan dijawab lewat stream; heartbeat dan pesan ganda diabaikan; stream putus
reconnect sekali lalu gagal dan pulih lewat coba lagi; init gagal; kirim gagal lalu kirim
ulang; paging history; jawaban sebelum konfirmasi kirim; halaman membuka sesi dan menutup
stream saat dilepas. UI test: pertanyaan dijawab lewat stream, header solid saat digulir dan
kembali transparan setelah history lama habis termuat, blocker offline.

## Style permukaan dan header — 22 Oktober 2026

DesignKit menambah `.cardStyle()` (isi, radius, garis tepi, bayangan) dan
`.designShadow()`. `MessageComposer` memakai `.cardStyle()`, jadi tampilannya tidak
berubah; radius pindah dari `CustomSizes.Composer` ke `CustomSizes.Card`.
`ScreenHeader` kini transparan saat diam dan putih saat digulir, dengan gradient
setinggi `spacingLarge` di bawahnya; material blur dan separator dihapus.

Dibuktikan oleh test: kedua modifier tidak mengubah ukuran layout; di app host,
warna piksel menunjukkan header tembus ke latar saat diam, putih saat digulir,
gradient di antara keduanya, dan latar kembali terlihat di bawah gradient.

## Tanya AI sebagai view SwiftUI — 22 Oktober 2026

`TanyaAIHost.makeViewController()` diganti `makeView()`: host SwiftUI tidak lagi
membungkus halaman ke `UIHostingController` lalu ke representable. Tampilan terang
dibatasi lewat `.environment(\.colorScheme, .light)`; tanpa `onBack`, tombol kembali
memakai `dismiss` SwiftUI. Sandbox mengikuti pola host: coordinator hanya berisi
`NavigationLink`, view model dipegang `@StateObject` di view tujuan
(`TanyaAIDestination`, `DetailDestination`), dan main dibuang saat logout.
`TanyaAIRouter` dan `TanyaAIPage` dihapus.

Dibuktikan oleh test: halaman full screen dan composer ada di halaman yang di-push;
render ulang halaman induk tidak mengganti halaman yang terbuka; UI test keyboard,
inset visual, swipe-back, buka dari detail, blocker offline, dan logout/login lulus.

## Host tiruan SwiftUI — 20 Oktober 2026

Sandbox kini meniru host: `RootScreen` (prelogin + main tetap hidup), base `Screen`,
`ScreenContentViewModel`, coordinator dengan tag, extension pop-gesture global, dan
`TanyaAIRouter` + satu link di base `Screen`. `RevampNavigationController`,
`SandboxRouter`, `SandboxHostView` dan `RevampNavigationTests` dihapus.

Dibuktikan oleh test:
- Tanya AI terbuka full screen dari beranda dan dari halaman detail tanpa didaftarkan
  per coordinator; ketukan ganda diabaikan; back kembali ke halaman asal;
- SwiftUI mem-pop beberapa halaman sekaligus saat Tanya AI terbuka: router ikut
  bersih dan Tanya AI bisa dibuka lagi;
- logout menutup Tanya AI; swipe-back hanya aktif bila ada halaman untuk kembali;
- UI test: `--offline` memunculkan blocker host di atas Tanya AI dan draft tetap ada
  setelah "Coba lagi"; logout lalu login kembali ke main.

Belum diuji pada perangkat iOS 15–17; simulator yang tersedia iOS 26.5.

## Host lebih sederhana — 20 Oktober 2026

`TanyaAIHostEnvironment` dan `HostEnvironmentReader` dihapus. `TanyaAIHost` menjadi
struct konfigurasi; `locale` dan `colors` dipasang ke environment saat halaman dibuat.
Live update dihapus karena bahasa diganti dari Settings dan theme dipilih saat inquiry
proposition, keduanya sebelum Tanya AI dibuka. Init `ChatScreen` tanpa konten yang
tidak dipakai juga dihapus.

Dibuktikan oleh test: `locale`/`colors` diterapkan pada halaman baru, perubahan
berlaku pada halaman berikutnya, dan halaman yang sudah terbuka tidak berubah.
Integrasi host SwiftUI (coordinator + base screen) diuji pada replika: halaman full
screen, blocker base screen tampil di atasnya, view model stabil saat parent render
ulang, dan logout menutup Tanya AI.

## Jalur navigasi host — 18 Oktober 2026

Tanya AI tidak lagi dipresentasikan sebagai modal dengan transisi custom. Host
mem-push `tanyaAI.makeViewController()` ke `RevampNavigationController` (contoh di
sandbox, yang kini memakai AppDelegate + SceneDelegate seperti host). Dihapus dari
package: anchor `.tanyaAIHost`, present/dismiss, transisi dan swipe custom, logika
menyembunyikan host, serta `CustomMotion` yang tidak lagi dipakai.

Dibuktikan oleh test:
- swipe-back native hanya aktif saat ada halaman untuk kembali; UI test dengan gesture
  jari: geser pendek batal, geser panjang kembali ke host;
- blocker UIKit (no internet) dan sheet SwiftUI dari main (session expired) tampil di
  atas Tanya AI;
- mengganti root window ke prelogin melepas Tanya AI; router tidak mem-push dua kali;
- halaman dan konten dilepas setelah pop; `locale`/`colors` diterapkan dan live.

UI test header kini menyasar scroll view konten secara eksplisit, karena
`scrollViews.firstMatch` bisa menunjuk bar saran keyboard.

## Tanpa literal di kode package — 18 Oktober 2026

`forwardDirection = 1` dan batas `1` pada swipe-back dihapus; arah dihitung dari lebar
layar dan arah layout. Transisi menjadi satu file tanpa pengecualian script, jadi
literal baru di sana akan ditolak. Parser hex memakai `HexFormat` dengan konstanta
format bernama dan urutan kanal `Channel`, tanpa mask/shift manual.

## Tanpa forcing — 18 Oktober 2026

`BoundedTextView` tidak lagi meng-override `text: String!`; `GrowingTextInput`
memanggil `remeasure()` setelah teks/style berubah. Bacaan `UITextView.text` memakai
`?? String()`. UI test memakai `let application = XCUIApplication()`. SwiftLint
mengaktifkan `force_unwrapping` dan `implicitly_unwrapped_optional` (ditambah
`force_cast`/`force_try` bawaan); keempatnya dibuktikan menolak pelanggaran sengaja.

## Struktur untuk skala — 18 Oktober 2026

Identifier UI test dikelompokkan per komponen; transisi akhirnya disatukan dalam satu file
`Host/TanyaAIPushTransition.swift` (164 baris, sebelumnya 271 baris di 3 file); fixture window test Sandbox di file sendiri; alias
`CustomColors.transparent` dihapus. Tipografi tetap memakai token `FigmaSize`
per role secara langsung.

## Pemisahan token custom — 18 Oktober 2026

`CustomSizes` dipecah menjadi `CustomSizes` (dimensi, selalu di-scale),
`CustomTextLines`, `CustomMotion`, `ArtworkScale`, dan `LayoutTolerance`. Perubahan
murni penggantian nama; nilai tidak berubah. `check_design_system.py` sekarang
menolak `CustomSizes` tanpa `.scaledToArtwork` serta baris/motion/toleransi yang
di-scale; kedua aturan dibuktikan dengan pelanggaran sengaja. `Scripts/verify.sh`
lulus: lint 0 pelanggaran, seluruh test package, hosted dan UI lulus.

## Kesiapan revamp — 17 Oktober 2026

Perubahan: host lifecycle (completion dismiss tidak hilang, `present()` → Bool,
fitur tertutup saat main diganti prelogin), swipe-back interaktif, theme lewat
environment, draft di `ComposerSection`, measurement editor hanya saat teks/lebar
berubah, nilai awal bawaan tipe, R.swift `from: "7.8.0"`.

`Scripts/verify.sh` lulus pada iPhone 17 Pro Simulator (Xcode 26), minimum iOS 15.
Saat dijalankan tanpa trust plugin R.swift, `xcodebuild` memerlukan
`-skipPackagePluginValidation`; script repo tidak diubah.

| Suite | Hasil |
| --- | --- |
| DesignKit: + theme environment (3), editor remeasure saat lebar berubah (1) | 15 lulus |
| TanyaAI: + animator saat host tertutup/swipe batal, interaksi swipe (3) | 10 lulus |
| Hosted: + present Bool, completion ganda, swipe batal + deeplink, main→prelogin, root UIKit diganti, `locale`/`colors` dari host awal dan saat terbuka | 15 lulus |
| UI: tiga bahasa, padding desain, keyboard, empat baris, header/menu | 11 lulus |

Total **51 tes lulus**. Belum ada pengukuran Instruments/FPS; swipe-back diuji
secara programatik melalui `UIPercentDrivenInteractiveTransition`, belum dengan
gesture jari pada device.

## Pembagian view dan ukuran desain — 17 Oktober 2026

Deklarasi view utama menyimpan input/state, initializer, `body`, dan bagian visual.
Setup, perhitungan dan validasi dipisah ke `private extension` Helpers pada file
yang sama; handler dipisah ke extension Actions. Stored properties tetap pada
deklarasi utama. Pemisahan source tidak menambah object, state, atau cache runtime.

Ukuran interaksi dan tebal stroke sekarang mengikuti nilai desain melalui
`.scaledToArtwork` langsung. Tidak ada minimum tap/stroke atau frame interaksi
tambahan dari SDK. Padding composer memakai `spacingLarge` di semua sisi tanpa
kompensasi inset. Font input tetap 14, maksimum empat baris, satu baris sejajar
tengah, dan tombol bertahan di bawah ketika editor membesar.

Verifikasi terbaru menggunakan `xcodebuild test` pada iPhone SE, iOS 26.5:

| Suite | Hasil |
| --- | --- |
| DesignKit: font, asset, sizing, editor, header, paste panjang/release | 11 lulus |
| TanyaAI: localization, anchor, animator | 7 lulus |
| Hosted: present/dismiss, release, caret, container, scroll boundary | 8 lulus |
| UI: tiga bahasa, padding desain, keyboard, empat baris, header/menu | 11 lulus |

Total **37 tes lulus**, tanpa kegagalan atau skip. Build dan lint lulus. Screenshot
native input kosong, empat baris dengan keyboard, serta header setelah scroll
diekspor dari hasil test dan diperiksa. Test UI sekarang memeriksa ukuran desain
langsung, tanpa mengasumsikan minimum tap SDK. Tidak ada pengukuran FPS/Instruments.

## Perubahan R.swift — 17 Oktober 2026

| Pemeriksaan perubahan terbaru | Hasil |
| --- | --- |
| SwiftLint, formatter, batas file/method, token/copy guard | Lulus, tanpa pelanggaran |
| Manifest DesignKit/TanyaAI dan referensi plugin/runtime pada project | Lulus |
| Generator R.swift untuk package dan sandbox project | Lulus |
| Kompilasi modul DesignKit/TanyaAI terhadap SDK iOS Simulator, minimum iOS 15 | Lulus melalui swiftc |
| Pemeriksaan tipe test kedua package dan sandbox dengan accessor generated | Lulus |
| Resource localization fitur dan sandbox | 20 assertion lulus pada macOS |
| Kompilasi tiga PDF imageset menjadi Assets.car | Lulus melalui actool |
| Full xcodebuild generic iOS Simulator dengan plugin/resource bundle | Lulus setelah cleanup mapping lama |
| Unit package pada simulator iOS 26.5 | 18 tes lulus: DesignKit 11, TanyaAI 7 |
| Hosted test dan UI automation terbaru | 19 tes lulus: hosted 8, UI 11 |
| Diff token generated dan tujuh font | Tidak berubah |

Pemeriksaan localization menjalankan source `String+Resource.swift` dan accessor
R.swift asli terhadap bundle berisi ketiga `.lproj`. Mencakup English, Indonesia,
`zh-Hans`, pemilihan Chinese untuk `zh_CN`, dan fallback English untuk `fr_FR`.

Full `xcodebuild` setelah cleanup berhasil menjalankan plugin R.swift pada target
package dan sandbox, mengompilasi xcassets serta membangun resource bundle asli.
Pemeriksaan swiftc sebelumnya hanya memakai accessor `Bundle.module` sementara
untuk pemeriksaan kompilasi. `AssetTests` kini lulus saat memuat ketiga ikon dari
bundle package yang sebenarnya pada simulator.

Percobaan awal sempat terhalang lingkungan dan ketidakcocokan CoreSimulator.
Setelah versi simulator sesuai, ketiga suite dijalankan ulang melalui
`xcodebuild test`: total 37 tes lulus seperti tercatat di atas. Screenshot dan
35 tes pada bagian berikut tetap **baseline 16 Oktober**; screenshot baseline
tidak menggambarkan seluruh perubahan asset dan aturan ukuran terbaru.

Audit terbaru juga menambahkan uji paste 19.000 karakter campuran Chinese/English.
Editor mempertahankan batas empat baris, scrolling aktif, menyusut setelah
dibersihkan, dan instance editor dilepas setelah pemiliknya berakhir. Ini menguji
tinggi dan lifecycle editor; bukan pengukuran FPS/latensi paste atau bukti bahwa
semua jalur aplikasi bebas memory leak.

App sandbox berhasil dipasang dan dijalankan pada simulator iPhone SE iOS 26.5.
Tes UI membuka fitur lewat tombol host, berinteraksi dengan header/composer,
lalu menutup dan membuka fitur kembali.

## Audit readability dan biaya runtime

View utama memiliki body ringkas dengan helper/aksi pada extension terpisah.
API SwiftUI standar, input immutable, state lokal, dan callback eksplisit membuat alur mudah
ditelusuri. Bagian lebih kompleks terisolasi pada editor UIKit dan animator
presentasi, dengan komentar alasan perilaku khusus. Pola view, callback dan
penempatan komponen ada pada [panduan view](VIEW_TEMPLATE.md).

- `ScreenContainer`, `ScreenHeader`, `MessageComposer`, `GrowingTextInput`, sizing,
  font dan scroll boundary sudah berada di DesignKit, tanpa ketergantungan fitur.
- Callback sederhana tetap memakai tipe closure langsung. Typealias hanya
  diperlukan ketika memberi nama kontrak domain yang kompleks/berulang.
- R.swift menghasilkan source saat build. Akses runtime tetap lookup resource.
  Microbenchmark macOS untuk enam label bersama mencatat sekitar 0,11 ms per
  kelompok pada 30.000 iterasi. Ini bukan benchmark rendering pada iPhone.
- Scroll menyimpan status Boolean dan melapor saat boundary berubah. Geometri
  tetap dibaca saat layout; tidak ada klaim bahwa cost scroll menjadi nol.
- Font didaftarkan sekali; editor menginvalidasi tinggi hanya ketika ukuran
  berubah. Measurement teks tetap dipengaruhi panjang input meskipun tinggi
  editor dibatasi empat baris.
- Audit reference menemukan weak anchor/presented controller, weak callback back,
  serta delegate yang diputus saat dismantle. Callback dari host tetap perlu
  capture ownership yang sesuai agar caller tidak membuat siklus sendiri.

Struktur ini layak sebagai baseline migrasi bertahap. Belum ada profil Instruments
Leaks/Allocations atau frame time pada device; jangan
mengartikan hasil unit test sebagai jaminan performa/bebas leak pada semua flow.
Pengukuran body/dependency mengikuti [panduan performa Apple](https://developer.apple.com/documentation/xcode/understanding-and-improving-swiftui-performance).

Tiga file mapping lama (`ChatCopy`, `SandboxCopy`, `SystemSymbol`) dan konstanta
rotasi ikon yang tidak dipakai sudah dihapus setelah persetujuan pengguna.

Ikon send/back/more kini berupa PDF vector dummy dalam xcassets, diakses lewat
R.swift. TODO penggantian export Figma ada pada README asset. Layout/padding,
ukuran font tetap 14, dan batas empat baris tidak diubah.

## Baseline — 16 Oktober 2026

`Scripts/verify.sh` lulus pada simulator iPhone SE 375×667, iOS 26.5.
Tiga tes UI header juga lulus saat dijalankan terpisah pada iPhone 17 Pro,
iOS 26.5 (402×874 point).

| Pemeriksaan | Hasil |
| --- | --- |
| DesignKit: registrasi tujuh font/glyph, hex, sizing, editor, header dan layout | 9 tes lulus |
| TanyaAI: locale, optional anchor/identity, pergantian host, animator | 7 tes lulus |
| Hosted unit: presentasi, lifecycle, caret, reusable container dan isolasi boundary | 8 tes lulus |
| UI: composer/caret, tiga bahasa, header, scroll, menu, keyboard dan tutup/buka | 11 tes lulus |
| Build generic iOS Simulator, deployment minimum iOS 15 | Lulus |
| SwiftLint/formatter, batas file/method, token/copy guard | Lulus |
| Link dokumentasi dan generated token diff | Lulus; generated token tidak berubah |

Total **35 tes unik**. Unit layout mencakup lebar 320/375/430 dengan normal dan
accessibility XXXL (font composer tetap). Sizing diuji sampai 1024 point tanpa cap.
Ini bukan pengujian UI iPad, runtime iOS 15/device atau pengukuran rendered FPS.

Pengujian presentasi memakai `TanyaAISandboxTests` dengan sandbox app sebagai
test host dan UIWindowScene aktif. SwiftPM unit tests hanya menangani layout
anchor/identity dan algoritma animator; logic test tanpa app tidak mempunyai
scene aktif untuk menyelesaikan transisi fullscreen. Target hosted test memakai
minimum iOS 17 sesuai toolchain test; minimum app/package tetap iOS 15.

## Pemeriksaan visual

Empat belas screenshot native berikut diekspor dari hasil UI test dan diperiksa.
Gambar tidak diedit atau dibuat dengan generator gambar.

- [English](../Artifacts/Screenshots/starter-en.png)
- [Bahasa Indonesia](../Artifacts/Screenshots/starter-id.png)
- [简体中文](../Artifacts/Screenshots/starter-zh-Hans.png)
- [Satu baris dan keyboard](../Artifacts/Screenshots/starter-one-line-keyboard.png)
- [Empat baris dan keyboard](../Artifacts/Screenshots/starter-four-lines-keyboard.png)
- [Pengaturan accessibility XXXL, font composer tetap](../Artifacts/Screenshots/starter-accessibility-zh-Hans.png)
- [Kosong dan fokus](../Artifacts/Screenshots/starter-empty-focused.png)
- [Caret setelah mengetik](../Artifacts/Screenshots/starter-caret-one-line.png)
- [Kosong setelah dihapus](../Artifacts/Screenshots/starter-empty-after-clearing.png)
- [Header dan awal konten dummy](../Artifacts/Screenshots/header-demo-top.png)
- [Header setelah scroll](../Artifacts/Screenshots/header-demo-scrolled.png)
- [Kembali ke atas](../Artifacts/Screenshots/header-demo-returned.png)
- [Awal konten di iPhone 17 Pro](../Artifacts/Screenshots/header-demo-top-large.png)
- [Setelah scroll di iPhone 17 Pro](../Artifacts/Screenshots/header-demo-scrolled-large.png)

Action tetap terlihat dan berada di atas keyboard. Teks panjang scroll di dalam
editor setelah empat baris. UI test memeriksa pusat field/tombol sejajar saat
kosong/satu baris dan posisi tombol tetap saat teks bertambah menjadi empat
baris atau lebih, pada pengaturan teks normal dan accessibility XXXL. Setelah kirim,
input menyusut dan kembali sejajar tengah. Ketujuh font Fira Sans/Open Sans terdaftar dengan
PostScript name yang dibaca dari file aslinya. Registrasi dua kali diuji aman;
Chinese memakai fallback glyph native pada setiap face, diuji tanpa glyph 0.
SF Symbol send/back/more masih dummy TODO. Verifikasi font brand final tetap mengikuti aset
resmi yang nanti diberikan, termasuk keputusan font Chinese brand.

Composer dan placeholder memakai token 14 dengan leading role 21, hanya mengikuti
artwork scaling; Dynamic Type tidak mengubah font/leading composer. UI test
membandingkan ukuran field kosong, satu baris, empat baris dan composer pada
pengaturan normal dengan accessibility XXXL: semuanya tetap sama.
Pada artwork 375, tes UI baseline memeriksa jarak 16 antara border dan lingkaran
tombol kanan/bawah, field kiri, serta field atas ketika multiline. Baseline saat
itu mempunyai area interaksi tambahan; aturan tersebut sudah diganti dengan
ukuran desain langsung pada 17 Oktober. Screenshot baseline tidak menjadi acuan
area interaksi implementasi terbaru.

Regresi caret direproduksi pada ketujuh font: koreksi yang hanya memusatkan caret
kosong ke bounds membuat posisinya berbeda 0,25–0,5 point dari caret saat mengetik.
Tes hosted gagal sebelum perbaikan dan lulus setelah geometri native dipakai pada
semua state. Rect caret di awal dokumen dibandingkan saat kosong, setelah mengetik
dan setelah menghapus draft: semuanya tetap sama. Hint dan input memakai font
yang sama; ZStack `.leading` memusatkan hint secara vertikal pada field.

Screenshot sekarang diambil setelah membuka feature melalui `.tanyaAIHost(host)`
dan `host.present()`. Header SwiftUI menyediakan judul, kembali dan menu titik tiga.
UI test memastikan tombol kembali
menutup feature dan presentasi berikutnya memulai draft kosong.

## Header dan scroll

Tes UI memeriksa judul di tengah, frame action back/more, jarak awal
konten dari header, perubahan boundary ketika scroll, mencapai akhir, lalu
kembali ke state awal. Header dan composer tetap pada posisi yang sama. Header
tetap stabil dengan keyboard dan input empat baris, termasuk pada pengaturan
teks accessibility XXXL. Menu diterjemahkan dalam tiga bahasa; tanpa handler sesi,
item “Percakapan baru” disabled. Pembuatan sesi/welcome belum diimplementasikan.

Screenshot memperlihatkan separator dan surface material setelah scroll; judul
tetap tajam. Unit layout menguji judul sangat panjang pada lebar 320/375/430,
dengan dan tanpa trailing action. Fallback Reduce Transparency memakai surface
opaque; pengaturan sistem ini belum diuji melalui otomasi UI.

Tes hosted memastikan injected content dilepas setelah dismiss walaupun host
masih dimiliki caller. Tes lifecycle existing juga lulus. Ini menguji ownership
jalur present/dismiss yang tersedia, bukan audit Instruments seluruh aplikasi.
Tes presentasi juga memastikan screen fitur tidak mempunyai UINavigationController
di dalam hierarchy-nya, sementara navigation stack host tetap utuh.

## Reuse dan pembatasan update scroll

`ChatScreen` menggunakan `ScreenContainer` DesignKit. Container menyimpan satu
Boolean, memakai ID UUID lokal melalui `@State`, dan memasang header/scroll/footer otomatis.
Modifier `.onScrollBoundaryChange` juga diuji terpisah dari fitur chat pada dua
ScrollView bertingkat: menggeser inner tidak mengubah status outer, dan sebaliknya.
Offset 0,2 point di bawah toleransi tidak memicu transisi. Enam perpindahan offset
di sisi boundary yang sama hanya menghasilkan satu transisi Boolean; kembali ke
atas menghasilkan satu transisi lagi. Nilai awal dikirim sekali saat muncul.

Tes container dengan beberapa child ViewBuilder memastikan inset header dan
margin diterapkan satu kali pada keseluruhan konten, bukan berulang per child.
Callback count ini membatasi update state; GeometryReader tetap mengevaluasi
geometri saat layout scroll berubah. Tidak ada klaim hasil FPS atau profiling
Instruments berdasarkan tes callback tersebut.
