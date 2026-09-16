# Status, informasi, suggestion, dan fallback

Kembali ke [kontrak event](../BUBBLE_SCHEMA.md). JSON di bawah adalah **payload `data`**, bukan envelope
vendor.

## `content.status`

Keempat field wajib, termasuk `detail` dan `level`. Level: `neutral`, `success`, `warning`, `error`; nilai
tidak dikenal menjadi neutral.

```json
{
  "messageIdentifier": "st-1",
  "title": "Selesai",
  "detail": "Permintaan Anda sudah diproses.",
  "level": "success"
}
```

[File JSON lengkap](../../Examples/BubbleResponses/status.json).

## `content.information`

Wajib: `messageIdentifier`, `text`, `items`. `title` opsional. Tetap kirim `items: []` jika tidak ada baris
label/value.

```json
{
  "messageIdentifier": "inf-1",
  "title": "Limit transfer",
  "text": "Limit harian Anda saat ini.",
  "items": [
    {
      "label": "Sesama bank",
      "value": "IDR 100.000.000"
    }
  ]
}
```

[File JSON lengkap](../../Examples/BubbleResponses/information.json).

## `response.suggestions`

Wajib: `suggestions`; tiap item wajib identifier/title/prompt. `title` opsional. Satu tap langsung mengirim
prompt; berbeda dengan choices yang menunggu submit. Tidak memakai `messageIdentifier` karena ini state saran,
bukan pesan dalam riwayat.

```json
{
  "title": "Kategori apa yang diinginkan",
  "suggestions": [
    {
      "identifier": "incoming",
      "title": "Dana masuk",
      "prompt": "Tampilkan dana masuk"
    }
  ]
}
```

[File JSON lengkap](../../Examples/BubbleResponses/suggestions.json).

## `content.future`

Untuk nama `content.*` yang belum didukung. `messageIdentifier` wajib; fallbackText opsional. Payload rusak
untuk bubble yang dikenal menampilkan pesan unsupported bawaan, bukan fallbackText ini.

```json
{
  "messageIdentifier": "future-1",
  "fallbackText": "Perbarui aplikasi untuk melihat kartu ini."
}
```

[File JSON lengkap](../../Examples/BubbleResponses/fallback.json).
