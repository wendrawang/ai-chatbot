# Komponen generik dan copy multilanguage

Update **DesignKit dan TanyaAI ke revisi yang sama**. Integrasi utama tetap
`TanyaAIHost` + `.tanyaAIHost(host)`; penggantian nama berlaku untuk view komponen,
bukan kontrak sesi SDK atau facade host.

## Memilih bahasa dan copy dari host

Paket menyediakan copy UI `en` dan `id`. Jika tidak diberi konfigurasi,
`CopyCatalog` mengambil bahasa pilihan perangkat saat dibuat. Bahasa yang belum
tersedia dan key terjemahan yang hilang fallback ke Inggris. Prioritasnya:
**override host → resource bahasa terpilih → resource Inggris → key**.

Host dapat memakai resource localization miliknya sendiri; isi dictionary harus
sudah berupa string dalam bahasa yang dipilih host. Override tidak melakukan
network request atau menjalankan closure di setiap row.

```swift
import TanyaAI

let copy = TanyaAICopyCatalog(
    localeIdentifier: "id",
    overrides: [
        "chat.title": "Tanya AI",
        "chat.subtitle": "",
        "chat.placeholder": "Tanyakan sesuatu",
        "chat.interrupted": "Koneksi terputus. Silakan coba lagi."
    ]
)
```

String contoh di atas milik **host**, bukan default package. Di project utama,
isi nilainya menggunakan accessor `.xcstrings` / `.strings` aplikasi Anda.
Tidak perlu menyalin semua key; key yang tidak dioverride memakai resource package.

Tambahkan `copy` pada pembuatan host yang sudah ada:

```swift
let host = TanyaAIHost(
    theme: selectedTheme,
    deeplinkScheme: appScheme,
    deeplinkHost: appDeeplinkHost,
    initialPrompt: nil,
    shortcuts: [],
    copy: copy,
    makeSession: makeChatSession,
    onDeeplink: handleDeeplink
)
```

`selectedTheme`, `appScheme`, `makeChatSession`, dan `handleDeeplink` adalah
nilai/fungsi integrasi Anda yang sudah ada. Tetap pasang `.tanyaAIHost(host)`
pada Main dan panggil `host.present()` dari tombol entry point.

Jika menggunakan `TanyaAIModule.makeViewController` secara langsung,
masukkan `copy` ke `TanyaAIConfiguration(copy: copy)`.

Konfigurasi host adalah **snapshot per instance**, termasuk copy untuk error
ViewModel dan layar PIN. Ketika bahasa aplikasi berubah, tutup presentasi lalu
buat host baru dengan copy bahasa baru. Mengganti `.locale` di Main saja tidak
mengganti konfigurasi fitur yang dipresentasikan melalui UIKit.

## Memakai DesignKit secara mandiri

```swift
import DesignKit
import SwiftUI

struct ProfileScreen: View {
    let copy: CopyCatalog
    let selectedTheme: Theme

    var body: some View {
        ProfileContent()
            .copyCatalog(copy)
            .theme(selectedTheme)
            .artworkLayout()
    }
}
```

`ProfileContent` adalah isi halaman host. Modifier `.copyCatalog` menyalurkan
copy dan locale ke subtree. Memberi nilai baru dari state host memperbarui
komponen SwiftUI yang memakai environment tersebut. Root UIKit lain harus
menerima environment secara eksplisit; bridge tabel chat sudah meneruskannya.

Komponen seperti `MessageComposer`, `LoadingStateView`, `SecureCodeIndicator`,
`ChoiceGroup`, dan `ActionLink` menerima label langsung dari caller. `NumericKeypad`
dan fallback aksesibilitas memakai resource DesignKit, dengan override
`design.digit`, `design.deleteDigit`, `design.responding`, `design.formattedResult`.

Tidak ada singleton bahasa yang diubah global, sehingga dua flow/window boleh
memakai bahasa berbeda. Template menggunakan placeholder bernama (`{count}`,
`{total}`, `{digit}`), bukan printf. Override mempertahankan nama placeholder
agar nilai dinamis tetap terbaca; teks dari pengguna tidak diproses ulang.

Daftar key lengkap:

- `Packages/DesignKit/Sources/DesignKit/Resources/en.lproj/Localizable.strings`
- `Packages/TanyaAI/Sources/TanyaAIPresentation/Resources/en.lproj/Localizable.strings`

Untuk bahasa baru, host bisa memberikan semua override dalam bahasa tersebut,
atau tambahkan pasangan resource localization package melalui alur terjemahan.
Pesan, judul card, prompt, serta label tombol **dari backend** tidak diterjemahkan
oleh package. Pilihan bahasa respons bot tetap menjadi kontrak host/backend.

## Pembagian komponen

| Lokasi | Komponen |
| --- | --- |
| DesignKit / Atoms | `GrowingTextInput`, `SelectionChip`, `SecureCodeIndicator`, `ActionLink`, `RoundedCorners` |
| DesignKit / Molecules | `MessageComposer`, `NumericKeypad`, `OptionRow`, `OptionList`, `OptionStrip`, `SummaryRow`, `LoadingStateView`, `TypingIndicatorView` |
| DesignKit / Organisms | `ResponseContent`, `ChoiceGroup` dan card kompleks yang sudah ada |
| DesignKit / Support/UIKit | `HostingTableViewCell<Content>`, `LayoutTrackingTableView` |
| TanyaAIPresentation | `ChatScreen`, `ConversationHistoryScreen`, `AuthorizationSheet`, adapter pesan dan approval |

`SelectionOption` hanya berisi identifier dan title. Payload aksi, prompt yang
dikirim, transaction ID, challenge PIN, serta aturan pilihan tetap berada di
TanyaAIDomain. `ChoicesBubble` mengadaptasi radio ke `ResponseContent` dan multi-select ke `ChoiceGroup` tanpa
membuat DesignKit bergantung pada domain chat. `ApprovalBubble`/`LiveAgentBubble`
tetap di fitur karena memahami status transaksi/handoff, bukan sekadar tampilan.

Nama view tidak mengandung `TanyaAI`. ViewModel dan kontrak SDK tetap memiliki
namespace fitur. Host yang hanya memakai facade tidak perlu mengganti nama-nama
internal. Caller yang mengimpor langsung view presentasi perlu mengganti:

| Sebelumnya | Sekarang |
| --- | --- |
| `TanyaAIChatView` | `ChatScreen` |
| `TanyaAIHistoryView` | `ConversationHistoryScreen` |
| `TanyaAIPINBottomSheetView` | `AuthorizationSheet` |
| `ChoiceChip` | `DesignKit.SelectionChip(title:...)` |
| `TanyaAIChatInputView` | `DesignKit.MessageComposer` (GrowingTextInput satu–empat baris) |
| `SuggestionList` / `ShortcutStrip` | `DesignKit.OptionList(options:...)` / `OptionStrip(options:...)` |
| `RestoringView()` | `DesignKit.LoadingStateView(label:...)` |
| `ActionLink(button:onTap:)` | `DesignKit.ActionLink(title:isUnderlined:onTap:)` |
| `TypingIndicatorView()` | `DesignKit.TypingIndicatorView(label:...)` |

`ChoicesPayload.submitTitle`, `LiveAgentPayload.continueTitle/cancelTitle`, dan
`TanyaAIMessageContent.unsupported` sekarang membawa teks optional. `nil`
memilih fallback lokal di presentation; teks backend yang ada tetap dipertahankan.
Caller yang membaca field tersebut langsung harus menangani optional.

`Suggestion.sandboxDefaults` dihapus; kirim daftar milik host atau biarkan `[]`.
Tidak ada greeting, suggestion, sample history, atau petunjuk PIN demo yang
dimasukkan otomatis oleh package produksi. Default title adalah “Chat”/
“Percakapan”, subtitle kosong. Respons bot yang datang tetap ditampilkan.

## Ukuran dan tipografi

Angka layout komponen diambil dari `DesignKitMetrics`, kemudian di-resolve lewat
`artwork.size`, `artwork.stroke`, atau `artwork.tapTarget`. Font memakai role
`theme.fonts` / `.designFont`, bukan angka ukuran pada view. Token tambahan yang
belum ada di export Figma berada di file mapping `Tokens/DesignKitMetrics*.swift`.
**Tidak ada perubahan pada `Tokens/Generated`.**

Token reference artwork default 375×812 dapat dioverride menjadi 374×812 di root.
Batas composer empat baris ada di `DesignKitMetrics.Text.maximumInputLines`.
Motion, opacity, tolerance pengukuran, dan batas HTML juga memiliki token bernama.
Lihat [setup font dan artwork](DESIGNKIT_MIGRATION.md) untuk skala dan Dynamic Type.

Nol layout, faktor matematika, digit keypad, PIN policy, batas cache/payload,
identifier protokol, SF Symbols, dan markup HTML bukan copy atau ukuran desain.
Fixture pada target `TanyaAITestSupport`, test, dan aplikasi sandbox tetap memiliki
data contoh. Target test support tidak boleh ditautkan pada Release host.

## Riwayat dan validasi

Daftar riwayat default kosong. Host dapat memasukkan
`historyItems: [TanyaAIConversationSummary]` pada host/configuration; judul dan
detail disediakan host. Ini adalah daftar ringkasan, belum menambah navigasi
pemilihan percakapan. Restorasi pesan aktif lewat session SDK tetap bekerja
melalui kontrak yang sudah ada.

`python3 Scripts/check_design_system.py` memeriksa pola literal UI, boundary
DesignKit, serta kelengkapan key/placeholder en/id. Pemeriksaan ini ikut
`Scripts/check_style.sh`. Guard tersebut melengkapi review, bukan pembuktian
bahwa setiap string/angka adalah salah atau bahwa runtime pasti bebas leak.

Lihat [hasil dan batas validasi](DESIGNKIT_VALIDATION.md). Jalankan verification
runtime iOS sebelum migrasi produksi luas.

Komposisi jawaban empat bagian dan integrasi host: [ANSWER_CONTENT.md](ANSWER_CONTENT.md).
