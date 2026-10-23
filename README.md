# Tanya AI — starting point

Baseline minimal untuk belajar dan migrasi bertahap, iOS 15. Menampilkan halaman
kosong, shared header, dan composer yang tumbuh sampai empat baris. Tujuh font Fira Sans/Open Sans dari package;
copy tersedia dalam English, Bahasa Indonesia, dan 简体中文.

```sh
./Scripts/run_sandbox.sh --language id
./Scripts/run_sandbox.sh --language en
./Scripts/run_sandbox.sh --language zh-Hans
./Scripts/run_sandbox.sh --language id --header-demo
./Scripts/run_sandbox.sh --language id --offline
```

Tombol kirim memanggil callback host. Sandbox menerima draft dan membersihkannya;
belum ada network atau bubble pesan. `--reject-send` mendemonstrasikan draft yang
harus dipertahankan saat host menolak submission.

Sandbox meniru host SwiftUI: `RootScreen` dengan prelogin dan main coordinator, base
`Screen` per halaman, dan coordinator + destination untuk membuka Tanya AI dari beranda
atau halaman detail.
Tombol kembali atau swipe dari tepi kiri menutup feature dan mengembalikan layar host.
`--offline` menampilkan blocker host di atas Tanya AI saat mengirim.
Mode `--header-demo` menyisipkan teks dummy untuk mengecek separator dan blur
saat scroll. Integrasi biasa tetap membuka area percakapan kosong.

- [Urutan belajar dan tree](docs/STARTING_POINT.md)
- [Tahap header dan checkpoint migrasi berikutnya](docs/SHARED_HEADER.md)
- [Membuka screen dari host app](docs/HOST_INTEGRATION.md)
- [Pola view dan resource R.swift](docs/VIEW_TEMPLATE.md)
- [Aturan implementasi](AGENTS.md)
- [Menjalankan tes (Xcode, workspace host, terminal)](docs/TESTING.md)
- [Hasil validasi](docs/VALIDATION.md)
- [Keputusan revamp dan tahap berikutnya](docs/REVAMP_NOTES.md)

PR starter ditujukan ke branch `startingpoint`; flow lengkap sebelumnya tetap
tersedia di `main`/history. Jalankan `Scripts/verify.sh` sebelum review.
