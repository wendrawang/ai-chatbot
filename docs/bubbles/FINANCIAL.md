# Approval, bukti transaksi, dan ringkasan keuangan

Kembali ke [kontrak event](../BUBBLE_SCHEMA.md). JSON di bawah adalah **payload `data`**, bukan envelope
vendor.

## `approval`

Wajib: semua field pada contoh kecuali `kind`, `notice`, dan `handoff` (tidak ditampilkan). `expiresAt`
ISO8601 harus berasal dari expiry challenge backend; tanggal 2099 hanya dummy. Tanpa `handoff`, konfirmasi
membuka PIN melalui authorization service host. Dengan `handoff:
{"identifier":"open-transfer","deeplink":"ocbcid://mobile?type=transfer"}`, konfirmasi menuju halaman host
tanpa PIN chat. `kind`: `generic` (default), `transfer`, `currencyConversion`, `timeDeposit`, `savingsPlan`.

```json
{
  "messageIdentifier": "apv-1",
  "approvalIdentifier": "apv-1",
  "transactionIdentifier": "trx-99",
  "challengeIdentifier": "chg-99",
  "title": "Konfirmasi transfer Anda",
  "summary": [
    {
      "label": "Ke",
      "value": "Sample Beneficiary"
    },
    {
      "label": "Jumlah",
      "value": "IDR 1.250.000"
    }
  ],
  "expiresAt": "2099-09-20T09:00:00Z"
}
```

[File JSON lengkap](../../Examples/BubbleResponses/approval.json).

## `receipt`

Wajib: `messageIdentifier`, `title`, `detail`, `summary`. `footnote` opsional. Ini hanya tampilan bukti; bukan
perintah melakukan transaksi.

```json
{
  "messageIdentifier": "rcp-1",
  "title": "Transfer berhasil",
  "detail": "Dana sudah diteruskan.",
  "summary": [
    {
      "label": "Nomor referensi",
      "value": "TRX-99812"
    }
  ],
  "footnote": "Simpan nomor referensi ini."
}
```

[File JSON lengkap](../../Examples/BubbleResponses/receipt.json).

## `chart`

Wajib: `messageIdentifier`, `title`, `chartType`, `series`. Setiap series wajib `label`, `value` numerik, dan
`formattedValue` untuk tampilan. `chartType` menerima bar/line/donut/progress; renderer saat ini menggambar
bar bersegmen untuk semuanya. Nilai enum tidak dikenal menjadi bar; field yang hilang tetap gagal decode.
`subtitle`, `totalValue`, `footnote` opsional.

```json
{
  "messageIdentifier": "cht-1",
  "title": "Pengeluaran bulan ini",
  "chartType": "bar",
  "series": [
    {
      "label": "Makan",
      "value": 2500000,
      "formattedValue": "IDR 2,5jt"
    },
    {
      "label": "Transport",
      "value": 1500000,
      "formattedValue": "IDR 1,5jt"
    }
  ],
  "totalValue": "IDR 4.000.000"
}
```

[File JSON lengkap](../../Examples/BubbleResponses/chart.json).

## `portfolio`

Wajib: `messageIdentifier`, `title`, `totalValue`, `performanceText`, `allocations`. Setiap allocation memakai
bentuk series chart. `footnote` opsional.

```json
{
  "messageIdentifier": "prt-1",
  "title": "Portofolio Anda",
  "totalValue": "IDR 128.400.000",
  "performanceText": "+4,2% sejak awal tahun",
  "allocations": [
    {
      "label": "Reksa dana",
      "value": 60,
      "formattedValue": "60%"
    }
  ]
}
```

[File JSON lengkap](../../Examples/BubbleResponses/portfolio.json).

## `financial_list`

Wajib: `messageIdentifier`, `title`, `style`, `rows`. Style: paidBills/incoming/holdings. Setiap row wajib
`title`, `value`; subtitle/detail/tone opsional. Tone: neutral (default), positive. `totalLabel`,
`totalValue`, `totalCaption`, `footnote` opsional; kirim total sebagai satu kelompok untuk tampilan yang
lengkap.

```json
{
  "messageIdentifier": "lst-1",
  "title": "Dana masuk 30 hari terakhir",
  "style": "incoming",
  "rows": [
    {
      "title": "Gaji",
      "subtitle": "02 Jul",
      "value": "IDR 12.000.000",
      "tone": "positive"
    }
  ],
  "totalLabel": "Total",
  "totalValue": "IDR 12.000.000",
  "totalCaption": "Seluruh dana masuk"
}
```

[File JSON lengkap](../../Examples/BubbleResponses/financial-list.json).
