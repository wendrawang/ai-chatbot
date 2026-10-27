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
/// Alur saat halaman dibuka: `start` → `history` → `config` (hanya bila history kosong) → `events`
/// (tetap terbuka selama halaman tampil). Chat dikirim lewat `send`; pesan user dan jawaban bot
/// sama-sama datang lewat `events`, jadi chat baru tampil saat diterima dari stream.
public protocol TanyaAIService {
    /// Init sesi. Body berisi `sessionId`.
    func start() async throws -> Data
    /// Satu halaman history, terbaru lebih dulu diambil; `before` = id pesan tertua yang sudah tampil.
    func history(sessionId: String, before messageId: String?) async throws -> Data
    /// Greeting dan shortcut untuk percakapan yang masih kosong.
    func config(sessionId: String) async throws -> Data
    /// Stream SSE persistent. Selesai atau error berarti koneksi putus.
    func events(sessionId: String) -> AsyncThrowingStream<TanyaAIServerEvent, Error>
    /// Kirim chat user. Sukses berarti BE menerima; pesannya tampil saat datang lewat `events`.
    func send(_ text: String, sessionId: String) async throws
    /// Hentikan jawaban untuk chat user `messageId` (id pesan user dari stream).
    func cancel(messageId: String, sessionId: String) async throws
}
