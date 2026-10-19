# Kontrak chat: SSE + inquiry per intent

Kontrak usulan sampai backend final. Bagian yang berubah cukup di satu tempat:
event SSE di `Service/ChatEvent.swift`, blok di `Service/ChatBlock.swift`, hasil BE
per intent di `Service/<Intent>Mapping.swift`.

## Alur

```
user kirim teks ──► host: SSE ke chat service ──► TanyaAI decode event
                                                   ├─ status  → "processing…" (loading)
                                                   ├─ delta   → teks jawaban bermarkup (streaming)
                                                   ├─ blocks  → tabel/pilihan/media/action/suggestion
                                                   └─ intent  → host: inquiry BE ──► mapping intent ──► blok jawaban
```

Host mengimplementasikan `TanyaAIService` (lihat [integrasi host](HOST_INTEGRATION.md)):

```swift
func streamChat(_ request: TanyaAIChatRequest) -> AsyncThrowingStream<TanyaAIServerEvent, Error>
func inquire(_ intent: TanyaAIIntent) async throws -> Data
```

Host hanya meneruskan event SSE apa adanya (`event:` → `name`, `data:` → `data`) dan
body JSON inquiry apa adanya. Stop atau tutup halaman membatalkan stream; tutup
koneksi SSE di `continuation.onTermination`.

## Event SSE

Satu koneksi per pertanyaan. `data` selalu JSON; field yang tidak dipakai boleh tidak ada.

| `event:` | `data:` | Efek |
| --- | --- | --- |
| `start` | `{"messageId":"m-42"}` | Awal jawaban |
| `status` | `{"text":"Processing the best answer for you..."}` | Teks loading + ikon berdenyut |
| `delta` | `{"delta":"Saya [bold]wen"}` | Ditambahkan ke teks jawaban (markup boleh terpotong) |
| `blocks` | `{"blocks":[ … ]}` | Blok non-teks setelah teks |
| `intent` | `{"intent":{"name":"review-porto","inquiryId":"inq-7f3","parameters":{"productType":"investment"}}}` | Setelah stream selesai, TanyaAI meminta host inquiry |
| `end` | `{}` | Jawaban selesai |
| `error` | `{"code":"SERVICE_UNAVAILABLE","isRetryable":true}` | Pesan gagal; `isRetryable` menampilkan chip "Coba lagi" |

Event tak dikenal (mis. `heartbeat`) dilewati.

- `inquiryId` unik per inquiry agar BE dapat membedakan setiap permintaan.
- `parameters` (`{String: String}`) berisi nilai yang diingat chat service, mis. autofill
  rekening/nominal untuk transfer dari jawaban sebelumnya.

## Blok jawaban

Dipakai sama oleh event `blocks` dan hasil mapping intent. Urutan blok = urutan tampil.
Jenis yang belum dikenal app dilewati, jadi backend boleh menambah jenis baru.

```json
{"type": "text", "text": "Saya [bold]wendra[/bold] …"}

{"type": "table",
 "columns": [{"title": "Produk"}, {"title": "Nilai Saat ini (IDR)", "isTrailing": true}],
 "rows": [["Reksa Dana", "35.000.000"]],
 "footer": {"label": "Total Keuntungan (IDR)", "value": "+3.600.000"}}

{"type": "options", "id": "product",
 "items": [{"id": "p1", "label": "#1 lorem ipsum options", "action": {"type": "prompt", "value": "…"}}]}

{"type": "media", "imageUrl": "https://…", "caption": "Jalani misinya…",
 "action": {"type": "link", "value": "https://…"}}

{"type": "actions", "items": [{"label": "action-here", "style": "filled", "action": {"type": "prompt", "value": "…"}}]}

{"type": "suggestions", "items": [{"label": "#1 suggested prompt", "action": {"type": "prompt", "value": "…"}}]}
```

- Tabel maksimal tiga kolom; angka rata kanan dengan `isTrailing`.
- Opsi tanpa `action` mengirim labelnya sebagai pertanyaan. Setelah dipilih, opsi menjadi
  riwayat read-only (centang hijau, opsi lain abu-abu).
- `style` action: `chip` (↳, default), `suggestion`, `link` (merah bergaris bawah), `filled`.

### Action

| `type` | `value` | Efek |
| --- | --- | --- |
| `prompt` | teks | Dikirim sebagai pertanyaan baru |
| `intent` | nama intent (+ `parameters`) | Langsung inquiry tanpa SSE; `inquiryId` dibuat app |
| `link` | URL | Diteruskan ke host lewat `onOpenLink` (lihat Link) |

Hanya jawaban terakhir yang action `prompt`/`intent`/opsinya aktif; `link` tetap aktif
di riwayat.

## Markup teks

Tag tertutup, bukan Markdown (karakter `*` lazim di copy perbankan):

```
Saya [bold]wendra[/bold], memiliki [strike]uang[/strike] maap maksud saya
[link]BISA DIKLIK|https://google.com[/link] dengan warna [color]hijau|25C36B[/color]
```

| Tag | Hasil |
| --- | --- |
| `[bold]…[/bold]` | Fira Sans SemiBold |
| `[strike]…[/strike]` | Dicoret |
| `[color]label\|HEX[/color]` | Warna hex (`RGB`, `RRGGBB`, `AARRGGBB`) |
| `[link]label\|target[/link]` | Merah, bergaris bawah, bisa diketuk |

- Tag tak dikenal dibuang, isinya tetap tampil. Kurung siku biasa (`[USD 100]`) tetap tampil.
- Aman untuk streaming: tag yang baru datang separuh (`[bo`) disembunyikan sampai lengkap;
  link/warna baru aktif setelah tag ditutup, jadi target separuh tidak pernah bisa diketuk.

### Link

| Target | Diteruskan ke host sebagai |
| --- | --- |
| `https://…`, `http://…` | `.web(url)` → webview host |
| `tel:1500999`, `tel://1500999` | `.phone(url)` |
| scheme lain (`ocbcid://…`) | `.deeplink(url)` → handler deeplink host |
| `javascript:`, `file:`, `data:`, `about:`, target tidak valid | Label tampil, tidak bisa diketuk |

## Inquiry per intent

TanyaAI memilih mapping dari nama intent (`Service/IntentMappings`). Intent tanpa mapping
menampilkan pesan "belum didukung". Kontrak BE berubah → ubah DTO + mapping intent itu saja.

### `review-porto` (DTO sementara)

```json
{
  "summary": "[bold]Evaluasi:[/bold] portofoliomu cenderung defensif …",
  "holdings": [{"product": "Reksa Dana", "currentValue": 35000000, "profit": 1200000}],
  "totalProfit": 3600000,
  "actions": [{"label": "Optimalkan portofolio", "style": "chip", "action": {"type": "prompt", "value": "…"}}]
}
```

Menjadi: teks `summary` → tabel Produk / Nilai Saat ini / Keuntungan (judul kolom
dilokalkan, angka diformat sesuai bahasa: `35.000.000`, `+1.200.000`) dengan footer total →
`actions`.

Menambah intent baru: buat `Service/<Nama>Mapping.swift` yang mengimplementasikan
`IntentMapping`, tambahkan nama di `IntentName`, lalu daftarkan di `IntentMappings`.
