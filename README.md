# Tanya AI — starting point

Baseline minimal untuk belajar dan migrasi bertahap, iOS 15. Menampilkan halaman
kosong, shared header, dan composer yang tumbuh sampai empat baris. Tujuh font Fira Sans/Open Sans dari package;
copy tersedia dalam English, Bahasa Indonesia, dan 简体中文.

```sh
./Scripts/run_sandbox.sh --language id
./Scripts/run_sandbox.sh --language en
./Scripts/run_sandbox.sh --language zh-Hans
./Scripts/run_sandbox.sh --language id --header-demo
```

Tombol kirim memanggil callback host. Sandbox menerima draft dan membersihkannya;
belum ada network atau bubble pesan. `--reject-send` mendemonstrasikan draft yang
harus dipertahankan saat host menolak submission.

Pada sandbox, tekan “Buka Tanya AI” untuk membuka feature fullscreen melalui
`.tanyaAIHost(host)` + `host.present()`, dengan animasi dari samping seperti flow
sebelumnya. Tombol kembali menutup feature dan mengembalikan layar host.
Mode `--header-demo` menyisipkan teks dummy untuk mengecek separator dan blur
saat scroll. Integrasi biasa tetap membuka area percakapan kosong.

- [Urutan belajar dan tree](docs/STARTING_POINT.md)
- [Tahap header dan checkpoint migrasi berikutnya](docs/SHARED_HEADER.md)
- [Membuka screen dari host app](docs/HOST_INTEGRATION.md)
- [Aturan implementasi](AGENTS.md)
- [Hasil validasi](docs/VALIDATION.md)

PR starter ditujukan ke branch `startingpoint`; flow lengkap sebelumnya tetap
tersedia di `main`/history. Jalankan `Scripts/verify.sh` sebelum review.
