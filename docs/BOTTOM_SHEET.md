# Bottom sheet DesignKit

Satu wadah untuk semua sheet: `.bottomSheet(...)` di `Components/Screen/BottomSheet`. Jangan memakai `.sheet` atau
membuat wadah lain per fitur. Wadah hanya memberi latar gelap, permukaan, grabber, tinggi, scroll, dan cara menutup;
judul, padding, dan isi milik pemakai.

## Cara pakai

Satu jenis sheet:

```swift
page
    .bottomSheet(isPresented: $isSheetPresented, closeLabel: closeLabel) {
        OptionList(title: title, items: items, selectedIDs: selectedIDs, onSelect: choose)
    }
```

Beberapa jenis sheet di satu halaman: satu pemasangan dengan enum jenis sheet. Sheet tampil selama nilainya ada, dan
menutup sheet mengosongkannya. Nilai lain membangun sheet baru, jadi centang sementara dan posisi scroll tidak
terbawa, dan fokus isi baru digulir ke layar.

```swift
page
    .bottomSheet(item: $model.sheet, closeLabel: closeLabel) { sheet in
        FormDemoSheetContent(model: model, sheet: sheet)   // switch sheet { case .format: ... case .accounts: ... }
    }
```

Contoh lengkap: `TanyaAISandboxApp/TanyaAI/TanyaAIScreen.swift` dan `FormDemo/` (`--form-demo`, `--sheet-demo`).

Aturan pemasangan:

- Pasang di root halaman, supaya latar gelap menutupi header dan composer.
- `closeLabel` dari copy pemakai; DesignKit tidak punya copy.
- Tinggi mengikuti isi. `maxHeight` hanya batasnya: bawaan tepat di bawah status bar, atau `.screenFraction(0.6)`.
- Host menahan swipe-back selama sheet terbuka (latar gelap hanya menahan sentuhan di dalam halaman); lihat
  `UINavigationController.setPopGestureEnabled` di sandbox.

## Aturan untuk isi sheet

- Isi tidak punya scroll vertikal sendiri. Isi yang lebih panjang dari batas digulir wadah.
- Bagian yang harus terlihat saat dibuka diberi `.id(BottomSheetFocus.id)`; wadah menggulirnya ke tengah.
  `OptionList` sudah melakukannya untuk pilihan pertama dari `selectedIDs`.
- State sementara boleh `@State` di dalam isi: wadah tidak membangun ulang isi saat isi bertambah panjang.
- Isi tidak memanggil service. Hasil pilihan atau input diteruskan lewat callback; service tetap di host.
- Nonaktif lewat `.disabled(...)`, teks lewat `.designFont(role)`.

## Isi yang sudah didukung

| Isi | Status | Catatan |
| --- | --- | --- |
| Daftar satu pilihan | Siap | `OptionList`, ketuk = selesai |
| Daftar banyak pilihan | Siap, satu batas | `OptionList(mode: .multiple)`; tombol konfirmasi ikut ter-scroll di daftar panjang |
| Daftar yang datanya menyusul | Siap | `items: nil` = spinner; daftar datang kemudian tanpa kehilangan centang |
| Pilihan sebelumnya langsung terlihat | Siap | `selectedIDs` dari pemakai |
| Isi statis: teks, kartu, tombol | Siap | Tinggi mengikuti isi |
| Keypad buatan sendiri (PIN) | Wadah siap, isi belum ada | Tidak memakai keyboard sistem; angka diteruskan ke host |
| Beberapa jenis sheet bergantian | Siap | `.bottomSheet(item:)` |

## Belum didukung, menunggu keputusan desain

| Kebutuhan | Keadaan sekarang | Yang perlu diputuskan |
| --- | --- | --- |
| Tombol yang menempel di bawah saat isi di-scroll | Tombol bagian dari isi, ikut ter-scroll | Apakah di Figma tombol "Pilih" menempel; bila ya, wadah butuh slot footer |
| Isi dengan field yang membuka keyboard | Sheet tidak naik mengikuti keyboard, field bisa tertutup | Apakah ada sheet berisi input teks (mis. pencarian) |
| Sheet yang tidak boleh ditutup | Selalu bisa ditutup lewat latar gelap, grabber, dan geser | Apakah sheet PIN boleh ditutup selama service berjalan |
| Layar tanpa notch (iPhone SE) | Sheet tanpa batas berhenti di y = 20; tarikan dari grabber diambil Notification Center | Jarak atas tambahan untuk layar tanpa notch |

Menambah salah satu di atas dilakukan di wadah (`BottomSheet`, `BottomSheetPresenter`), bukan di isi, supaya semua
sheet mendapatkannya.
