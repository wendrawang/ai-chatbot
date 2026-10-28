# Chat-gateway Tanya AI (contract 1.0.1)

Pembagian kerja host ↔ TanyaAI untuk gateway ICT. Sumber kebenaran contract tetap
`chat-gateway/docs/contract.md` milik BE; dokumen ini hanya menjelaskan bagian yang dipakai iOS.

## Siapa mengerjakan apa

| Host (`TanyaAIChatTransport`) | TanyaAI (`TanyaAIBridge`) |
| --- | --- |
| Base URL, header `X-OCBCNISP-OMNI-SESSION` dan `-CHANNEL`, SSL pinning, log | Urutan init → history → SSE dan menyambung ulang |
| Mengirim request per endpoint, mengembalikan body mentah | Decode envelope, `Message`, error, frame SSE |
| Melempar `TanyaAITransportError.response` untuk non-2xx | Retry/backoff, merge history tanpa duplikat |
| Login ulang saat `onSessionExpired` | Pesan ditampilkan hanya dari stream; `turn_end` membuka kirim |

Welcome/shortcut tetap dari BE host (inquiry proposition) dan di-decode host; contract ICT
di-decode TanyaAI karena khusus Tanya AI dan sama di semua host.

## Endpoint yang dipakai

| Fungsi transport | Endpoint |
| --- | --- |
| `initialize()` | `POST /chat/init`, body `{}` |
| `history(conversationID:before:limit:)` | `GET /chat/conversations/{id}/messages?limit=&before=` |
| `sendMessage(conversationID:clientMessageID:text:)` | `POST /chat/messages`, body `{conversation_id, client_msg_id, type:"text", payload}` → 202 |
| `events(conversationID:lastEventID:)` | `GET /chat/conversations/{id}/events`, `Accept: text/event-stream`, `Last-Event-ID` bila ada |

Typing, cancel, limits, list conversations, dan close belum dipakai.

## Alur

1. Halaman tampil (`.task` di `ChatScreen`): init → history halaman terbaru → buka SSE dengan
   `Last-Event-ID` = `seq` terbesar di daftar. Event di antara history dan stream ikut di-replay;
   duplikatnya digabung lewat `message_id`.
2. Stream putus atau error `retryable:true`: jeda 1, 2, 4, … maks 30 detik (atau `retry_after_ms`
   dari 429/503), lalu ulang dari init. History baru diambil per halaman sampai bertemu pesan terakhir
   yang sudah ada, baru sisanya ditambahkan. Jeda kembali ke 1 detik setelah stream tersambung.
3. Berhenti: halaman ditutup (task dibatalkan), init mengembalikan `CLOSED` (history tetap tampil),
   401 (`onSessionExpired`, sekali), atau error lain dengan `retryable:false`.
4. Kirim: ack 202 hanya mengunci composer. Pertanyaan tampil saat event `message` miliknya datang,
   jawaban bot menyusul, `turn_end` membuka kunci. Kirim gagal = draft tetap di composer.

Percakapan dari init berbeda dengan sebelumnya (yang lama diarsipkan) mengganti daftar.

## Contoh transport di host

```swift
final class TanyaAIChatService: TanyaAIChatTransport {
    func events(conversationID: String, lastEventID: String?) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var request = makeRequest(path: "/chat/conversations/\(conversationID)/events")
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    request.setValue(lastEventID, forHTTPHeaderField: "Last-Event-ID")
                    let (bytes, response) = try await session.bytes(for: request)
                    try validate(response) // non-2xx → TanyaAITransportError.response(statusCode:body:)
                    for try await line in bytes.lines { continuation.yield(line) }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
```

`bytes.lines` membuang baris kosong; parser TanyaAI tetap memisahkan frame pada baris `id:`
berikutnya. `makeRequest` menambah base URL dan header OMNI. Jangan log isi pesan.

## Belum diputuskan

- Percakapan baru: `X-New-Conversation: true` dibatasi 1 percakapan per CIF (409), endpoint
  close belum dipakai. Menu "Percakapan baru" sementara hanya memanggil host.
- Paging history lebih lama saat scroll ke atas, tampilan pesan `canceled`, payload non-teks,
  typing indicator, dan tombol stop (`cancel`).
