# Contoh

Tiga file yang perlu Anda tulis sendiri di project Anda, dan tidak lebih.

| Folder | Isi |
| --- | --- |
| [`HostIntegration`](HostIntegration) | Memasang fitur ke app existing: `TanyaAIHost`, plus adapter otorisasi dan theme milik Anda |
| [`VendorChatSDK/Sendbird`](VendorChatSDK/Sendbird) | Adapter Sendbird, composition root, dan lifecycle: kapan memanggil initialize / connect / disconnect |

File di sini bukan bagian dari target sandbox. Salin ke project Anda, lalu
ganti placeholder `Host*`/`App*` dengan tipe milik Anda sendiri.
