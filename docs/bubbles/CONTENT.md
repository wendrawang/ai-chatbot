# Gambar, pilihan, link, HTML, dan live agent

Kembali ke [kontrak event](../BUBBLE_SCHEMA.md). JSON di bawah adalah **payload `data`**, bukan envelope
vendor.

## `image`

Wajib: `messageIdentifier`, `imageURL`, `caption`. `caption: ""` menyembunyikan caption. `aspectRatio` adalah
lebar ÷ tinggi; default 16:9. Rasio tetap selama download; gambar dipotong sesuai rasio ini. URL yang gagal
dimuat menampilkan placeholder. `accessibilityText` opsional.

```json
{
  "messageIdentifier": "img-1",
  "imageURL": "https://cdn.example.com/promo.png",
  "caption": "Bonus bunga hingga 5,25% p.a.",
  "aspectRatio": 1.6,
  "accessibilityText": "Amplop merah berisi koin"
}
```

[File JSON lengkap](../../Examples/BubbleResponses/image.json).

## `choices`

Wajib: `messageIdentifier`, `choices`; setiap pilihan wajib `identifier` dan `title`. `prompt` default ke
`title`. `allowsMultipleSelection` default `true`; nama key JSON ini tetap meskipun property Swift memakai
`isMultipleSelectionAllowed`. Tombol submit mengirim prompt pilihan digabung `", "` sesuai urutan daftar.
Setelah submit, pilihan terkunci.

```json
{
  "messageIdentifier": "q-1",
  "title": "Kategori apa yang diinginkan",
  "choices": [
    {
      "identifier": "dining",
      "title": "Dining",
      "prompt": "Promo dining"
    },
    {
      "identifier": "travel",
      "title": "Hotel",
      "prompt": "Promo hotel"
    }
  ],
  "allowsMultipleSelection": false,
  "submitTitle": "Kirim"
}
```

[File JSON lengkap](../../Examples/BubbleResponses/choices.json).

## `actions`

Wajib: `messageIdentifier`, `actions`; setiap tombol memiliki `title` dan `action` (`identifier`, `deeplink`).
`style` opsional: `primary` (default, underline) atau `secondary`. Daftar kosong menjadi bubble unsupported.
Tidak ada heading; kirim penjelasan sebagai pesan teks terpisah. Host memvalidasi deeplink.

```json
{
  "messageIdentifier": "act-1",
  "actions": [
    {
      "title": "Lihat Produk Sekarang",
      "action": {
        "identifier": "open-product",
        "deeplink": "ocbcid://mobile?type=product"
      }
    }
  ]
}
```

[File JSON lengkap](../../Examples/BubbleResponses/actions.json).

## `html`

Wajib: `messageIdentifier`, `html`. Kirim `height` dalam point dan `accessibilityText`. Tanpa tinggi, default
180 lalu diukur ulang. Hanya HTML statis: JavaScript, link, form, redirect, dan iframe diblokir. Resource
absolut seperti gambar masih dapat dimuat. Chart sebaiknya memakai `chart`.

```json
{
  "messageIdentifier": "html-1",
  "html": "<table><tr><th>Tenor</th><th>Imbalan</th></tr></table>",
  "height": 120,
  "accessibilityText": "Tabel tenor dan imbalan"
}
```

[File JSON lengkap](../../Examples/BubbleResponses/html.json).

## `live_agent`

Wajib: `messageIdentifier`, `title`, `action` (`identifier`, `deeplink`). `detail` opsional. Label tombol
default Continue/Cancel. Lanjut meneruskan deeplink; batal menandai kartu selesai tanpa mengirim pesan.

```json
{
  "messageIdentifier": "agent-1",
  "title": "Anda akan diarahkan ke agen kami",
  "detail": "Agen A siap membantu Anda.",
  "continueTitle": "Lanjut",
  "cancelTitle": "Batal",
  "action": {
    "identifier": "open-live-agent",
    "deeplink": "ocbcid://mobile?type=live-agent"
  }
}
```

[File JSON lengkap](../../Examples/BubbleResponses/live-agent.json).
