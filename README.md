# Tanya AI — starting point

Baseline minimal untuk belajar dan migrasi bertahap, iOS 15. Menampilkan halaman
kosong, shared header, dan composer yang tumbuh sampai empat baris. Tujuh font Fira Sans/Open Sans dari package;
copy tersedia dalam English, Bahasa Indonesia, dan 简体中文.

```sh
./Scripts/run_sandbox.sh --language id
./Scripts/run_sandbox.sh --language en
./Scripts/run_sandbox.sh --language zh-Hans
./Scripts/run_sandbox.sh --language id --long-history
./Scripts/run_sandbox.sh --language id --offline
./Scripts/run_sandbox.sh --language id --slow-reply --reset-terms
```

Host menampilkan T&C sekali sebelum Tanya AI dibuka pertama kali. Saat dibuka, Tanya AI
menjalankan init sesi, mengambil history, memuat greeting dan shortcut bila history kosong, lalu
membuka stream SSE yang tetap hidup. Chat dikirim lewat service terpisah; pesan user dan jawaban
tampil saat datang dari stream, dan jawaban bisa dihentikan. Sandbox memakai service dummy dari
fixture JSON (`saldo`, `transfer`, `promo`, `markdown`, selain itu jawaban default); kontraknya
di [CHAT_CONTRACT.md](docs/CHAT_CONTRACT.md).

Sandbox meniru host SwiftUI: `RootScreen` dengan prelogin dan main coordinator, base
`Screen` per halaman, dan coordinator + destination untuk membuka Tanya AI dari beranda
atau halaman detail.
Tombol kembali atau swipe dari tepi kiri menutup feature dan mengembalikan layar host.
`--offline` membuat init sesi gagal: blocker host tampil di atas Tanya AI.
`--long-history` mengisi history panjang untuk mencoba paging dan header saat digulir.
`--slow-reply` memperlambat pantulan dan jawaban untuk melihat loading dan mencoba stop; `--reset-terms` menampilkan T&C lagi.

- [Urutan belajar dan tree](docs/STARTING_POINT.md)
- [Tahap header dan checkpoint migrasi berikutnya](docs/SHARED_HEADER.md)
- [Membuka screen dari host app](docs/HOST_INTEGRATION.md)
- [Pola view dan resource](docs/VIEW_TEMPLATE.md)
- [Aturan implementasi](AGENTS.md)
- [Menjalankan tes (Xcode, workspace host, terminal)](docs/TESTING.md)
- [Hasil validasi](docs/VALIDATION.md)
- [Keputusan revamp dan tahap berikutnya](docs/REVAMP_NOTES.md)

PR starter ditujukan ke branch `startingpoint`; flow lengkap sebelumnya tetap
tersedia di `main`/history. Jalankan `Scripts/verify.sh` sebelum review.
