# Contoh

Contoh integrasi host dan beberapa pilihan SDK chat.

| Folder | Isi |
| --- | --- |
| [`HostIntegration`](HostIntegration) | Memasang fitur ke app existing: `TanyaAIHost`, plus adapter otorisasi dan theme milik Anda |
| [`VendorChatSDK/Sendbird`](VendorChatSDK/Sendbird) | Adapter Sendbird, composition root, dan lifecycle: kapan memanggil initialize / connect / disconnect |
| [`VendorChatSDK/Tencent`](VendorChatSDK/Tencent) | PoC Tencent Chat Core SDK: lifecycle, sesi C2C, history, dan wiring RootScreen/AppState/MainCoordinator |

File di sini bukan bagian dari target sandbox. Salin ke project Anda, lalu
ganti placeholder `Host*`/`App*` dengan tipe milik Anda sendiri.
