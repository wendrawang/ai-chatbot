# Performance dan lifetime

Draft composer lokal agar setiap ketikan tidak mempublikasikan seluruh daftar.
Row memiliki observed message object; update konten memperbarui row tersebut.
History dibatasi 100 pesan. Langganan row/hosted cells dilepas saat detach,
callback tertunda weak dan pekerjaan ukuran/posisi dicoalesce dengan batas pass.

UITableView menggunakan self-sizing hosted SwiftUI cells dan posisi scroll
terukur. UIHostingConfiguration dipakai pada iOS 16+; containment controller
pada iOS 15. Root table memakai plain UIViewController agar perubahan keyboard
cukup ditangani SwiftUI, tanpa inset keyboard kedua dari UITableViewController.

Unit tests memeriksa 150 pesan→100, eviction, batch teks, anchored scrolling,
repeated render/dismiss dan pelepasan graph. Frame-rate monitor menghitung
cadence callback display link di simulator, bukan rendered FPS perangkat.

Hasil regresi/stress dan batas validasi: [FIGMA_CHAT_VALIDATION.md](FIGMA_CHAT_VALIDATION.md).
Pengukuran perangkat nyata, SDK dan backend baru dilakukan setelah integrasi host.
