# Tanya AI — starting point

Baseline minimal untuk belajar dan migrasi bertahap, iOS 15. Menampilkan halaman
kosong dan composer yang tumbuh sampai empat baris. Font Open Sans dari package;
copy tersedia dalam English, Bahasa Indonesia, dan 简体中文.

```sh
./Scripts/run_sandbox.sh --language id
./Scripts/run_sandbox.sh --language en
./Scripts/run_sandbox.sh --language zh-Hans
```

Tombol kirim memanggil callback host. Sandbox menerima draft dan membersihkannya;
belum ada network atau bubble pesan. `--reject-send` mendemonstrasikan draft yang
harus dipertahankan saat host menolak submission.

- [Urutan belajar dan tree](docs/STARTING_POINT.md)
- [Membuka screen dari host app](docs/HOST_INTEGRATION.md)
- [Aturan implementasi](AGENTS.md)
- [Hasil validasi](docs/VALIDATION.md)

PR starter ditujukan ke branch `startingpoint`; flow lengkap sebelumnya tetap
tersedia di `main`/history. Jalankan `Scripts/verify.sh` sebelum review.
