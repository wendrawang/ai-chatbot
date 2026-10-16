# Migrasi bertahap — prototype BI FAST

Created by Wendra. Sumber branch adalah `main` (`9a88d91`). Instruksi terbaru dan
[rule prototype](TANYAAI_RULES.md) menjadi acuan. File lama masih ada dan sebagian
tidak disertakan dalam target aktif; penghapusannya menunggu pilihan Wendra.

## Urutan belajar dan integrasi

1. **DesignKit:** pertahankan `Tokens/Generated`, tujuh font dan lisensinya.
   Pelajari `CustomSizes`, semantic color mapping, `InitialValues`, `FontFace`,
   `FontLoader`, dan `DesignTypography`. Font dimuat sekali dari Bundle.module.
   Generated spacing numerik tidak dipakai komponen; gunakan Small/Medium/Large.
2. **Composer:** mulai dari `GrowingTextInput` + `BoundedTextView`, kemudian
   `MessageComposer`. Font placeholder dan input sama. Satu baris berada di tengah;
   action mengikuti bagian bawah ketika input tumbuh. Lebih dari empat baris
   menggulir di dalam editor. `ContentSizeHostingController` memberi ukuran footer
   pada UIKit iOS 15. Tidak perlu view model untuk tiap komponen.
3. **Domain:** pelajari plain models dan empat kontrak di TanyaAIDomain. Semua
   dependency wajib diinjeksi; nominal memakai Decimal dan currency eksplisit.
4. **Harness dahulu:** jalankan DemoConfiguration, builder, mock services dan
   InMemoryConversationHistoryStore. Ini target contoh terpisah; host production
   tidak perlu menautkannya. Jangan salin mock authorizer ke transaksi production.
5. **Chat dan satu flow:** ChatViewModel owns pesan/sesi, satu TransferFlowViewModel
   owns lifecycle per flow. UIViewController owns instance stabil; cell hanya
   menampilkan. Step SwiftUI menerima input dan callback, tanpa VM/service sendiri.
6. **Produksi berikutnya:** setelah desain/kontrak disepakati, implementasi service,
   secure authorization, persistent history, routing webview/deeplink dan intent
   tambahan berada di milestone terpisah. Jangan menghubungkan API banking nyata
   untuk mencoba prototype.

## Integrasi host

Tambahkan produk `TanyaAIFeature` dan `TanyaAIDomain` dari package TanyaAI. Nama
produk/initializer berbeda dari SDK lama yang masih tersimpan di repository.
Tidak ada NavigationLink atau NavigationView baru di dalam fitur.

Host membuat dependency **sekali per sesi**, lalu menyimpan `TanyaAISession`:

```swift
import TanyaAIDomain
import TanyaAIFeature

let session = try TanyaAISession(
    context: context,
    dependencies: dependencies,
    configuration: configuration,
    onLink: onLink,
    onClose: onClose)

// Host UIKit mempresentasikan session.navigationController secara full screen.
// Host SwiftUI memasang sekali pada root yang stabil:
rootView.tanyaAIHost(isPresented: $isChatPresented, session: session)
```

`onClose` memperbarui binding host menjadi false (SwiftUI) atau dismiss controller
(UIKit). Session mempertahankan flow ketika tampilannya ditutup; submit/pending
bukan cancelled. `session.updateLanguage("zh-Hans")` memperbarui UI tanpa membuat
ulang flow atau memanggil inquiry/submit. Teks jawaban lama tetap menjadi history
bahasa saat pesan tersebut dibuat. Harness mengganti bahasa melalui halaman awal.

`onLink(URL)` milik host: URL web dibuka dengan webview milik host, scheme app
melalui handler deeplink host. Prototype tidak membuka Safari atau jaringan.
Implementasi production perlu memvalidasi tujuan dan aturan routing host.

## State dan resource

Inquiry dikunci sebelum await dan ditandai flow/session/revision. Perubahan sumber
atau draft membatalkan quote; review perlu inquiry baru. Cancellation juga tersedia
pada inquiry karena belum ada transaksi yang disubmit. PIN Back saat idle kembali
ke review; keluar ketika authorizer masih bekerja membatalkan challenge dan kembali
ke editing agar respons lama tidak dapat memicu submit.

History memakai snapshot aman: authorizing menjadi reviewing, inquiring menjadi
editing dan submitting menjadi pending. Restore tidak otomatis melakukan service.
Receipt/cancelled tetap readonly; tampilan lama tidak menghidupkan form kembali.
Source quote/receipt, fee, total, waktu dan referensi berasal dari satu flow.

Strings dihasilkan R.swift per target dan dipilih dengan bahasa host; bukan
Bundle.main atau daftar key literal. Host resource, feature resource dan resource
umum tidak saling mengakses R.generated.swift. Output R.swift dan token generated
bukan tempat menambah nilai manual. Clean Build Folder diperlukan setelah perubahan
key resource pada versi plugin yang dipakai.

## Penghapusan belum dilakukan

[Daftar lengkap](PROPOSED_DELETIONS.md) merupakan usulan, bukan izin penghapusan.
Wendra memilih file yang boleh dihapus terlebih dahulu. Setelah itu daftar exclude,
source lama, test/dokumen/artefak dapat dirapikan tanpa menghapus design token.
