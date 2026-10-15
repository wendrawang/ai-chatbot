# Integrasi host UI terbaru

Mulai dengan [migrasi DesignKit bertahap](DESIGNKIT_PHASED_MIGRATION.md), lalu
pasang package TanyaAI. Backend/vendor belum dipilih; demo memakai
MockTanyaAIChatSession.figma() pada Debug. Produksi mengimplementasikan
TanyaAIChatSession untuk satu percakapan.

1. Tambah DesignKit dan TanyaAI sebagai package dependency. Jangan memasukkan
   TanyaAITestSupport ke Release host.
2. Own satu TanyaAIHost pada AppState/session owner setelah login aplikasi.
   Siapkan theme/copy/welcome dan factory sesi; jangan membuat graph di body.
3. Pasang `.tanyaAIHost(host)` pada root yang sudah terlihat; panggil
   `host.present()` dari tombol entry. Host optional boleh tetap nil sebelum login.
4. Factory `makeSession` memberikan adapter baru setiap presentasi. Factory
   `makeNewSession` memberikan percakapan baru/empty, bukan adapter sesi aktif
   yang sama. Default tidak mengirim invisible prompt.
5. `onDestination` membuka webview milik host; `onDeeplink` menerima URI app
   yang sudah difilter scheme/host. Host tetap memvalidasi tujuan/domain.
6. `onHostFlow` membuka dokumen/PIN existing di atas presenter yang diberikan.
   Panggil completion setelah halaman selesai/dismiss. Kembalikan accepted,
   cancelled, processing/completed atau failure; jangan mengirim PIN ke chat.

```swift
let host = TanyaAIHost(
    theme: theme,
    deeplinkScheme: appScheme,
    deeplinkHost: appEntryHost,
    copy: copy,
    welcome: welcome,
    makeSession: makeChatSession,
    makeNewSession: makeEmptyChatSession,
    onDestination: openWebview,
    onHostFlow: presentExistingDocumentOrPIN,
    onDeeplink: handleDeeplink
)
```

Nama fungsi/nilai contoh adalah dependency aplikasi host, bukan fungsi bawaan
package. Signature bridge dan contoh request/result ada di
[FIGMA_CHAT_UI.md](FIGMA_CHAT_UI.md). Untuk UIKit gunakan
`TanyaAIModule.makeViewController(configuration:dependencies:onHostFlow:makeNewSession:onAction:)`
dan present controller secara full screen.

`TanyaAIHost` menunggu dismissal sebelum membuka stack host pada action
webview/deeplink. `onHostFlow` mempertahankan chat/draft dan mempresentasikan
halaman existing di atas chat. Completion terlambat/duplikat dari sesi lama
maupun request yang sudah selesai tidak mengubah sesi baru.

Pada logout, dismiss lalu lepaskan host dan adapter. Model melepas callback/
disconnect; adapter bertanggung jawab melepas listener/channel sendiri tanpa
melogout SDK global milik flow lain. Theme adalah snapshot per presentasi;
`themeProvider` bisa mengambil theme terkini saat chat dibuka.

Katalog kontrak tampilan lama sudah dihapus. Gunakan `response.blocks` untuk
jawaban terstruktur. `authorizationService`, `onConfirmation`, `shortcuts`
dan `historyItems` tidak lagi merupakan parameter host/configuration.
