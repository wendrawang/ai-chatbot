//
//  TanyaAIService.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import Foundation

/// Jaringan Tanya AI milik host. TanyaAI tidak membuka koneksi sendiri: host memanggil BE,
/// lalu mengembalikan body JSON apa adanya. Bentuk JSON ada di `docs/CHAT_CONTRACT.md`.
///
/// Alur saat halaman dibuka: `start` → `history` → `events` (tetap terbuka selama halaman tampil).
/// Chat user dikirim lewat `send` terpisah; jawaban bot datang lewat `events`.
public protocol TanyaAIService {
    /// Init sesi. Body berisi `sessionId`.
    func start() async throws -> Data
    /// Satu halaman history, terbaru lebih dulu diambil; `before` = id pesan tertua yang sudah tampil.
    func history(sessionId: String, before messageId: String?) async throws -> Data
    /// Stream SSE persistent. Selesai atau error berarti koneksi putus.
    func events(sessionId: String) -> AsyncThrowingStream<TanyaAIServerEvent, Error>
    /// Kirim chat user. Body berisi pesan user yang sudah tersimpan di BE (dengan `id`).
    func send(_ text: String, sessionId: String) async throws -> Data
}

/// Satu event SSE: nama dari baris `event:` dan isi dari baris `data:`.
public struct TanyaAIServerEvent: Equatable, Sendable {
    public let name: String
    public let data: Data

    public init(name: String, data: Data) {
        self.name = name
        self.data = data
    }
}
