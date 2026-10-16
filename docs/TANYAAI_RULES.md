**TanyaAI — Aturan implementasi prototype transfer**
Versi 1.0 • 16 Oktober 2026 • Minimum iOS 15 • Bahasa dokumen: Indonesia

Dokumen ini adalah pedoman implementasi untuk developer dan AI coding assistant. Milestone sekarang adalah prototype interaktif dengan data dummy untuk melihat rendering dan perpindahan flow transfer di dalam chat. Dokumen ini tidak menyatakan implementasi sudah dibuat atau sudah diuji.
Instruksi terbaru pemilik project mengungguli dokumen ini. Sebelum mengubah project, baca aturan repository dan struktur existing; pertahankan perubahan yang sudah dibuat developer lain.

**01. Kerjakan scope berikut secara eksplisit.**

| Area | Scope milestone ini |
|---|---|
| Chat | Satu percakapan, composer, jawaban dummy, suggestion, satu flow transaksi aktif |
| Intent | Transfer BI FAST; pemicu deterministik dari suggestion atau pesan fixture |
| Transfer | Input nominal/metode/keperluan/catatan → inquiry dummy → ringkasan → PIN dummy → submit dummy → receipt |
| Rich text | Bold, strikethrough, warna semantic, link pada sebagian teks |
| Transport | MockConversationService di host/harness; tidak ada koneksi WebSocket nyata |
| Service banking | MockTransferService dan mock otorisasi; tidak memanggil API transaksi existing |
| History | Pesan selama sesi tersimpan di memory melalui interface; database lokal persisten ditunda |
| Resource | Resource package dan accessor generated; lokalisasi id, en, dan Chinese |
| Intent lain | Biller, investment, advisory, e-statement belum diimplementasikan |
| Media | Upload file/gambar belum diimplementasikan; composer tidak menawarkan fitur yang belum tersedia |
| Integrasi production | mTLS, socket nyata, callback adapter production, database, telemetry production adalah milestone berikutnya |

Prototype harus benar-benar interaktif. Tombol yang aktif harus menghasilkan perubahan state atau aksi yang jelas. Jangan mengganti interaksi dengan screenshot, video, maupun rangkaian halaman statis.
Tampilkan penanda “Mode demo — tidak ada transaksi nyata” di harness/chat dan penanda demo pada receipt. Jangan menggunakan rekening, nama nasabah, nomor referensi, atau kredensial nyata dari foto.

**02. Gunakan foto sebagai referensi visual, dengan data flow yang konsisten.**

| Referensi pengguna | Elemen yang terlihat dan harus diterjemahkan |
|---|---|
| 1000107518.jpg — input | Header Masukkan Nominal; penerima/avatar/bank/rekening; nominal besar; metode; keperluan; catatan dengan counter; ucapan; pilihan waktu |
| 1000107524.jpg — ringkasan | Rekening sumber dengan Ubah; penerima; jumlah; biaya admin asli dicoret dan biaya efektif; kuota benefit; metode; waktu; keperluan; total; dua CTA |
| 1000107521.jpg — receipt | Penanda brand; ikon berhasil; sumber/penerima; tanggal/jam; nominal; metode; tanggal transfer; referensi; Kembali; affordance share |
| PIN — deskripsi pengguna | Indikator PIN tersamarkan dan keypad angka seperti kalkulator; tidak ada screenshot untuk menyalin detail lain |

Foto receipt berasal dari transaksi berbeda dari foto input/ringkasan. Salin hierarki dan gaya tampilannya; seluruh nilai receipt demo wajib berasal dari draft/quote/submission flow yang sedang dijalankan.
Screenshot menunjukkan layar penuh. Adaptasikan kontennya menjadi satu kartu flow di timeline TanyaAI; jangan mengubah chat menjadi empat layar banking terpisah.
Header utama tetap “TanyaAI”. Judul tahap tampil di dalam kartu. Jangan meniru status bar perangkat di screenshot.
Gunakan permukaan putih, pemisah tipis, avatar bulat, aksen merah, teks gelap, dan sukses hijau dari token Design System. Radius, shadow, spacing, serta font wajib berasal dari token.
Pertahankan pengelompokan informasi tanpa memaksakan banyak lapisan kartu di dalam kartu. Jangan menetapkan tinggi bubble secara tetap.
Logo hanya menggunakan asset yang tersedia dan memang disediakan project. Jika belum tersedia, harness menggunakan wordmark “BANK DEMO” yang jelas sebagai placeholder demo.

**03. Catat asumsi prototype berikut; jangan menyebutnya aturan bisnis production.**

- Intent pertama adalah transfer BI FAST, satu penerima, satu mata uang IDR, dan waktu transaksi Sekarang.
- Jumlah digit PIN belum diberikan. Fixture prototype memakai 6 digit melalui configuration; konfirmasi sebelum integrasi otorisasi production.
- Chinese sementara memakai zh-Hans. Jika project menggunakan zh-Hant, ikuti project; pilihan script harus tercatat sebelum handover.
- Label CTA input yang terpotong pada foto ditetapkan “Lanjut” untuk demo.
- Batas catatan 25 karakter berasal dari counter yang terlihat pada foto; simpan dalam configuration, bukan literal tersebar pada view.
- “Kirim sebagai Ucapan”, “Terjadwal”, “Berkala”, “Tambah Transfer Lain”, dan share receipt tampil sebagai kontrol nonaktif dengan penjelasan “Belum tersedia pada demo”. Jangan berpura-pura menjalankan fitur tersebut.
- Picker metode dan keperluan memakai daftar fixture. Untuk tahap pertama boleh hanya BI FAST dan Transfer Dana; picker tetap membuka, menunjukkan pilihan aktif, dan dapat ditutup.
- Tombol Ubah rekening sumber menampilkan pilihan rekening dummy. Perubahan sumber membatalkan quote lama dan membutuhkan inquiry baru.
- Nilai nominal awal, rekening sumber/penerima, biaya, kuota, waktu, delay, dan hasil service berasal dari fixture/configuration yang diinjeksi.

**04. Gunakan struktur kecil dan dependency satu arah.**

~~~text
BankApp/
├── App/Integrations/TanyaAI/
│   ├── TanyaAIBuilder.swift
│   ├── MockServices/
│   ├── Fixtures/
│   └── InMemoryConversationHistoryStore.swift
├── Packages/
│   ├── BankDesignSystem/
│   │   ├── Package.swift
│   │   └── Sources/BankDesignSystem/
│   │       ├── Tokens/
│   │       ├── Components/
│   │       ├── ScreenChrome/
│   │       └── Resources/
│   └── TanyaAI/
│       ├── Package.swift
│       ├── Sources/
│       │   ├── TanyaAIDomain/
│       │   │   ├── Models/
│       │   │   ├── Contracts/
│       │   │   └── Errors/
│       │   └── TanyaAIFeature/
│       │       ├── PublicAPI/
│       │       ├── Navigation/
│       │       ├── Chat/
│       │       ├── Transfer/
│       │       ├── Rendering/
│       │       └── Resources/
│       └── Tests/
└── Examples/TanyaAIHarness/
~~~

- BankDesignSystem berisi token dan komponen presentasi bersama. Jangan menaruh service, aturan transaksi, maupun TransferFlowViewModel di dalamnya.
- TanyaAIDomain berisi plain models, enum state/error yang relevan, dan kontrak. Jangan mengimpor UIKit, SwiftUI, networking library, atau model host.
- TanyaAIFeature bergantung pada TanyaAIDomain dan BankDesignSystem. Host bergantung pada kedua target TanyaAI yang diperlukan.
- Implementasi service tetap dimiliki host. Harness adalah host kecil untuk demo dan dapat mengompilasi mock/fixture sebagai target support khusus; target production tidak menyertakan fixture otomatis.
- Jangan membuat dependency package → HostApp. Jangan membuat target TanyaAIData pada milestone ini.
- TanyaAIBuilder membuat dependency dan pemilik flow satu kali saat membuka sesi. Jangan merakit dependency dari body SwiftUI.
- Factory fitur menerima context, dependency, dan callback output. Gunakan initializer biasa; dependency wajib tidak memiliki fallback singleton.
- Kontrak minimum: ConversationServicing, TransferServicing, ConversationHistoryStoring, dan TransactionAuthorizing. Gunakan tipe domain pada parameter/hasil.
- Kontrak conversation mendukung open/event stream, send, dan close. Mock dan implementasi nyata kelak harus bisa diganti melalui kontrak yang sama.
- Service inquiry/submit/status menyediakan async/await. Adapter callback production kelak berada di host. Continuation satu-hasil tidak digunakan untuk banyak event socket.
- Jangan memasukkan certificate, private key, PIN, access token, atau konfigurasi mTLS ke dalam package TanyaAI.

**05. Gunakan template view sesuai tanggung jawabnya.**

| Jenis | Template |
|---|---|
| Komponen stateless | Satu View; input bertipe dan closure action; tanpa ViewModel |
| Interaksi visual lokal | View dengan State/Binding seperlunya, misalnya expand/collapse |
| Chat | ChatViewController, ChatViewModel, ChatState, ChatTableDataSource, Composer, Cells |
| Transfer | TransferFlowView, TransferFlowViewModel, TransferFlowState, Steps, Components |
| Step transfer | TransferAmountView, TransferSummaryView, TransferPINContainer, TransferReceiptView; menerima data/action |
| Rich text | RichTextParser dan RichTextRenderer terpisah dari cell |
| Header/scaffold | Konfigurasi navigation bar bersama dan ScreenScaffold untuk layout; tanpa service |

Satu TransferFlowViewModel memiliki satu flowID dan seluruh lifecycle flow. Step nominal, ringkasan, dan receipt tidak masing-masing memiliki ViewModel/service sendiri.
Komponen PIN boleh memiliki object UI lokal khusus untuk input sementara; nilai digit tidak boleh masuk TransferFlowState, ChatState, atau model history.
ChatViewModel menangani percakapan; TransferFlowViewModel menangani transaksi. Jangan membuat ChatViewModel mengimplementasikan seluruh langkah transfer.
Urutan isi ViewModel: dependency, state, initializer, action publik bernama jelas, lalu helper privat. Contoh action: updateAmount, selectMethod, continueTapped, editTapped, confirmTapped, retryStatusCheck.
Gunakan enum state dan switch biasa. Jangan memperkenalkan framework reducer, event bus global, BaseViewModel universal, service locator, atau registry plugin generik.
UIKit chat root menggunakan UITableView dan diffable data source. View SwiftUI untuk isi flow boleh di-host melalui satu adapter cell yang benar untuk iOS 15.
UIHostingController di cell harus mengelola containment, reuse, dan self-sizing. ViewModel flow dimiliki pemilik sesi, bukan cell; jangan membuat ulang hosting controller untuk setiap token.
NavigationStack dan UIHostingConfiguration tidak tersedia pada iOS 15. Coordinator memakai UINavigationController; integrasi ke host SwiftUI dilakukan pada boundary fitur.
Gunakan property wrapper dasar SwiftUI saat dibutuhkan. Hindari Observable/Model macro, custom dependency wrapper, serta annotation arsitektur baru. MainActor boleh dipakai terbatas pada pemilik UI untuk menjelaskan isolasi UI; jangan menghilangkan keselamatan concurrency demi mengurangi annotation.
Jika SwiftUI memiliki object, gunakan StateObject; child menggunakan ObservedObject. Jika controller memiliki object, controller mempertahankan instance yang stabil. Jangan membuat instance baru setiap render.
ScreenScaffold mengatur background, safe area, content, serta footer. Header memakai satu pemilik navigasi; perubahan bubble tidak melakukan push screen.

**06. Terapkan state transition transfer berikut.**

| State | Event | Perilaku berikutnya |
|---|---|---|
| editing | Lanjut dengan input valid | Set inquiring sebelum memulai satu inquiry dummy |
| editing | Input tidak valid | Tetap editing, tampilkan error field, tanpa request |
| inquiring | Quote sukses untuk revision aktif | reviewing dengan quote tersebut |
| inquiring | Gagal | Error yang dapat dicoba ulang; draft tetap tersedia |
| reviewing | Edit/ubah sumber/metode/nominal | Kembali editing; invalidasi quote dan otorisasi lama |
| reviewing | Konfirmasi | authorizing; tampilkan PIN dummy di bubble yang sama |
| authorizing | Kembali | reviewing; hapus seluruh digit PIN sementara |
| authorizing | PIN lengkap, mock menerima | submitting; hanya satu submit untuk command aktif |
| authorizing | Mock menolak | Tetap authorizing, hapus digit, tampilkan pesan demo |
| submitting | Sukses | succeeded dengan receipt dari quote/submission aktif |
| submitting | Status belum diketahui | pending; tombol Periksa Status, tidak submit ulang |
| pending | Mock status sukses | succeeded dengan referensi transaksi yang sama |
| succeeded | Kembali | Composer siap untuk pesan baru; receipt tetap ada sebagai history read-only |
| editing/reviewing/authorizing | Batalkan | Tandai flow cancelled, bersihkan input PIN, jangan submit |

- Simpan request revision sebelum await. Abaikan respons dengan flowID, sessionID, atau revision yang sudah tidak aktif.
- Saat submitting/pending, keluar tampilan tidak berarti transaksi dibatalkan; pemilik sesi tetap mengelola hasil. Prototype mensimulasikan perilaku ini.
- Pisahkan callback UI dari efek service. body, computed property, init view, serta kemunculan ulang cell tidak boleh memanggil inquiry/submit.
- Jangan mengganti messageID atau flowID ketika tahap berubah. Buat ID baru hanya untuk flow baru.
- Receipt wajib mengambil penerima, sumber, nominal, metode, biaya, total, dan referensi dari flow yang sama. Jangan memakai fixture receipt lepas yang bertentangan.
- Nominal memakai Decimal atau integer unit uang dengan aturan currency yang eksplisit. Jangan memakai Double.
- Format tampilan mengikuti locale; nilai domain tidak disimpan sebagai string berformat. Pisahkan input kosong dari nominal nol.
- State loading mengunci action transaksi terkait, bukan seluruh percakapan. Tap berulang tidak menambah jumlah inquiry/submit.

**07. Implementasikan isi setiap tahap dengan perilaku yang jelas.**

- Input: avatar/penerima/bank/rekening, amount input, picker metode dan keperluan, catatan/counter, waktu Sekarang, serta CTA Lanjut.
- Validasi: nominal wajib, lebih besar dari nol, sesuai batas fixture; input tidak valid tidak memanggil service. Counter catatan mengikuti karakter pengguna, termasuk Chinese dan emoji.
- Summary: sumber/Ubah, penerima, jumlah, biaya asli dicoret bila diskon berlaku, biaya efektif, kuota benefit bila tersedia, metode, waktu, keperluan, catatan bila ada, total, dan Konfirmasi.
- Total dihitung dari quote fixture yang konsisten: nominal ditambah biaya efektif. Label benefit/biaya tidak boleh ditulis sebagai aturan produk nyata.
- PIN: judul otorisasi demo, indikator dot, grid 1–9, baris terakhir dengan 0 dan hapus, action Kembali; tidak ada operator matematika atau keyboard teks.
- PIN demo memakai panjang dari configuration dan menerima digit apa pun yang lengkap pada skenario sukses. Jangan menyimpan atau memeriksa PIN nyata maupun menanam PIN rahasia tetap seperti 123456.
- Setelah jumlah digit lengkap, panggil mock authorizer satu kali. Tombol angka dikunci selama validasi; hapus digit saat gagal, kembali, keluar, atau selesai. PIN tidak pernah ditulis ke log/fixture/analytics/history.
- Receipt: penanda demo/brand, ikon sukses, judul “Simulasi transfer berhasil”, sumber tersamarkan, penerima, tanggal/jam, nominal, metode, tanggal transfer, referensi DEMO, Kembali.
- Pending: tampilkan status belum diketahui dan Periksa Status. Jangan menampilkan receipt sukses sebelum skenario status mengembalikan sukses.
- Semua informasi tetap terbaca pada layar kecil dan Dynamic Type. Chat memiliki scroll vertikal utama; hindari scroll vertikal kedua di dalam kartu flow.

**08. Buat fixture yang deterministik dan mudah diganti.**

- Simpan fixture di host/harness: TransferScenario, ConversationScenario, DemoConfiguration, dan mock services. Jangan menaruh data dummy pada property default di view atau ViewModel.
- Contoh fixture yang diperbolehkan: nama PENGIRIM DEMO/PENERIMA DEMO, rekening dummy, nominal IDR 10.000, biaya asli IDR 2.500, biaya efektif IDR 0, kuota 141/150. Nilai ini khusus demonstrasi.
- Sediakan waktu tetap yang diinjeksi, sequence event, ID pesan/flow/quote stabil, dan referensi berawalan DEMO. Tidak boleh memakai UUID baru dari body.
- Sediakan configuration untuk digit PIN, batas catatan, batas nominal demo, daftar metode/keperluan, pilihan rekening, dan delay mock.
- Script percakapan minimal: greeting → suggestion Transfer BI FAST → intent dengan penerima dummy → kartu transfer. Pesan tak dikenal mendapat jawaban fallback lokal yang jelas.
- Kenali pemicu deterministik seperti suggestion atau kata “transfer”; jangan membuat panggilan model AI maupun pencocokan bebas yang tampak seperti engine production.
- Mock harus mengikuti bentuk event yang disepakati internal. Format wire backend belum diketahui; jangan menyatakan fixture JSON sebagai kontrak backend yang sudah disetujui.
- Skenario minimum: sukses, inquiry gagal lalu retry, PIN ditolak lalu diterima, submit pending lalu status sukses, event intent duplikat, respons inquiry terlambat.
- Satu intent eventID yang dikirim ulang tidak boleh membuat dua bubble flow. Incoming intent baru saat flow aktif mendapat respons untuk menyelesaikan/membatalkan flow aktif terlebih dahulu.
- Delay menggunakan operasi asynchronous yang bisa dibatalkan. Jangan memakai sleep yang memblokir main thread.

**09. Terapkan rich text, timeline, resource, dan history tanpa efek samping rendering.**

- Grammar dummy: [bold]teks[/bold], [strike]teks[/strike], [color=success]teks[/color], [link=https://example.com]teks[/link]. Ini kontrak internal prototype.
- Parser mengeluarkan text runs/style; renderer menghasilkan NSAttributedString untuk UITextView. Gunakan font, strikethrough, warna semantic, dan link pada range yang tepat.
- UITextView untuk jawaban tidak editable dan tidak scroll vertikal sendiri. Link dapat dipilih; tap diteruskan ke output handler host. Harness memperlihatkan tujuan link tanpa request jaringan.
- Uji tag bersarang yang didukung, tag tidak dikenal, tag rusak, escaping kurung siku, emoji, dan Chinese. Fallback harus menampilkan teks aman tanpa crash; jangan menafsirkan HTML atau script.
- Mock streaming harus mencakup tag yang terpotong antar-chunk. Buffer token tag yang belum lengkap dan tampilkan hanya bagian yang valid; final message menjalani parsing final.
- Cache hasil rendering per messageID, revision, locale, dan konfigurasi typography. Jangan mem-parsing ulang seluruh history untuk satu perubahan pesan.
- Update hanya row yang berubah; hindari reloadData untuk setiap chunk. Pertahankan fokus input dan posisi scroll saat tinggi bubble berubah.
- Autoscroll hanya ketika pengguna berada dekat bawah atau baru mengirim pesan. Saat membaca history, jangan merebut posisi scroll.
- Resource umum milik BankDesignSystem; resource TanyaAI milik TanyaAIFeature. Host R.generated.swift tidak dapat dipakai langsung dari package.
- Tambahkan dependency/plugin R.swift per target yang membutuhkan, dengan versi/toolchain yang kompatibel. Accessor asset/string dihasilkan otomatis; jangan menulis daftar nama asset manual.
- Gunakan bundle resource target package. Jangan mencari asset package secara implisit di Bundle.main.
- Semua teks UI, accessibility label, validation, placeholder, dan penanda demo masuk resource lokal. Jangan merangkai kalimat terjemahan dari potongan string.
- Lokalisasi awal: id, en, zh-Hans sesuai asumsi. Bahasa aktif diinjeksi host; perubahan bahasa tidak membuat flow baru atau mengulang service.
- In-memory history menyimpan pesan dan snapshot aman per customer/session. PIN, raw authorization data, dan secret tidak termasuk.
- State authorizing tidak dipulihkan dari history. Snapshot terminal read-only; restore/scroll tidak memicu inquiry atau submit.
- Tampilan retained history dalam sesi harus bekerja; kehilangan history setelah restart harness adalah perilaku milestone ini yang harus dilaporkan.

**10. Tegakkan coding rules berikut pada kode yang ditulis tim.**

- Maksimal 250 baris per file Swift dan 50 baris per method/initializer; pecah tanggung jawab, bukan memadatkan statement. Generated/vendor code dikecualikan dan tidak diedit manual.
- Gunakan Allman braces: kurung pembuka berada pada baris berikutnya. Closure juga multiline; jangan membuat beberapa statement dalam satu baris.
- Tidak ada baris kosong antar stored property. Ada satu baris kosong antar method. Hindari baris kosong yang tidak diperlukan di dalam method.
- Boolean buatan tim memakai prefix is, termasuk parameter. Signature framework/protocol eksternal mengikuti nama aslinya.
- Tidak ada nested if atau rantai if/else. Gunakan guard/early return dan switch state. else pada guard diperlukan oleh sintaks dan diperbolehkan.
- Untuk ViewBuilder, gunakan switch atau conditional sederhana yang tidak bertingkat; jangan memaksakan early return dengan AnyView hanya untuk melewati aturan.
- Dependency/state wajib diinisialisasi eksplisit. Jangan memberi dummy default seperti amount = 0, account = "", customer = "-", atau service = Singleton.shared.
- Nilai awal semantik seperti collection kosong/idle dapat dibuat di initializer/factory state. Angka desain berada di token; nilai demo berada di fixture; batas perilaku berada di configuration.
- Jangan menambah library arsitektur/DI/rich-text sebelum kebutuhan konkret terbukti. Pilih API platform yang tersedia di iOS 15.
- Gunakan formatter/lint repository. Sesuaikan rule opening brace dengan Allman agar tool tidak saling bertentangan.
- Pembaruan UI wajib di main thread/MainActor. async/await tidak otomatis memindahkan pekerjaan berat ke background.
- Jangan memakai force unwrap, force cast, atau unchecked Sendable untuk membungkam persoalan lifecycle/concurrency.
- Komentar menjelaskan alasan atau invariant. Public API kecil; helper implementation tetap internal/private. Jangan membuat protocol untuk setiap view.
- Tidak ada auto-submit dari onAppear, perubahan locale, reuse cell, restore snapshot, atau reconnect event.

**11. Implementasikan berurutan dan buktikan setiap bagian.**

1. Periksa repository, toolchain, aturan lokal, deployment target, resource generator, dan entry point host yang tersedia.
2. Buat package/target minimum, kontrak, fixture, mock service, dan harness yang bisa dibuka.
3. Buat shell chat, composer, suggestion, rich text, serta timeline dengan ID stabil.
4. Implementasikan satu transfer sukses lengkap: input → ringkasan → PIN → receipt.
5. Tambahkan back/edit/cancel, invalidasi quote, state gagal/pending, dan skenario event duplikat/terlambat.
6. Verifikasi tiga bahasa, layout, keypad, scroll, reuse, dan kepatuhan coding rules.
7. Catat cara menjalankan harness, skenario yang tersedia, hasil build/test, serta keterbatasan milestone.
Jangan memperluas milestone ke socket production, intent lain, upload, database, atau revamp app existing tanpa instruksi scope berikutnya.

**12. Kriteria penerimaan sebelum menyebut prototype selesai.**

- [ ] Harness dapat dibangun dan dibuka pada target iOS 15; semua pemakaian API sesuai deployment target.
- [ ] Suggestion/pesan fixture memunculkan satu flow; nominal, metode, keperluan, dan catatan merespons interaksi.
- [ ] Input valid → satu inquiry; tap berulang/scroll/render ulang tidak menggandakan request.
- [ ] Ringkasan dan receipt konsisten dengan data aktif; perubahan draft menginvalidasi quote sebelumnya.
- [ ] Satu messageID tetap dipakai dari input sampai receipt; receipt lama tidak menjadi form aktif lagi.
- [ ] PIN demo berfungsi, dapat dihapus, tersamarkan, dan tidak muncul dalam message model/history/log.
- [ ] Back dari summary/PIN mempertahankan data nonsensitif sesuai aturan dan membersihkan PIN.
- [ ] Pending tidak diperlakukan sebagai gagal atau sukses; Periksa Status tidak mengirim submit baru.
- [ ] Rich text mendukung empat style, substring link, Unicode, dan potongan streaming tanpa crash.
- [ ] Posisi scroll/fokus tetap masuk akal ketika bubble berubah ukuran atau keyboard muncul.
- [ ] Teks tiga bahasa dan Dynamic Type terbaca; kontrol nonaktif mempunyai penjelasan demo.
- [ ] Tidak ada request jaringan/transaksi nyata; fixture, mock, dan penanda demo dapat dikenali.
- [ ] Test bermakna meliputi transisi, hitungan request, stale response, duplicate intent, parser, dan konsistensi receipt.
- [ ] Handover menyebut bahwa socket, persistence setelah restart, media, dan intent lain belum termasuk.
Jangan menyatakan build/test/performance lulus tanpa menjalankannya. Bila toolchain tidak tersedia, laporkan batas verifikasi dan berikan langkah menjalankan yang jelas.

**Referensi teknis untuk keputusan platform.**
- [Navigasi SwiftUI dan batas iOS 16](https://developer.apple.com/documentation/swiftui/migrating-to-new-navigation-types)
- [Integrasi SwiftUI dengan UIKit dan UIHostingConfiguration](https://developer.apple.com/videos/play/wwdc2022/10072/)
- [R.swift untuk target Swift Package](https://github.com/mac-cain13/R.swift#packageswift-based-spm-project)
- [Resource/lokalisasi Swift Package](https://developer.apple.com/documentation/xcode/localizing-package-resources)
- [UITextView dan attributed text](https://developer.apple.com/documentation/uikit/uitextview)
