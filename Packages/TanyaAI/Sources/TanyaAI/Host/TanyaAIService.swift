//
//  TanyaAIService.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import Foundation

/// Seam backend yang diimplementasikan host. Host memegang jaringan (SSE, token, inquiry);
/// TanyaAI hanya men-decode event dan memetakan hasil per intent. Kontrak: docs/CHAT_CONTRACT.md.
/// `Sendable` karena dipanggil dari task di luar main thread; class dengan properti `let`
/// (URLSession, URL, konfigurasi) otomatis memenuhinya.
public protocol TanyaAIService: AnyObject, Sendable {
    /// Buka SSE ke chat service dan alirkan setiap event apa adanya. Stream dibatalkan saat
    /// pengguna menekan stop atau menutup halaman; tutup koneksi di `onTermination`.
    func streamChat(_ request: TanyaAIChatRequest) -> AsyncThrowingStream<TanyaAIServerEvent, Error>

    /// Inquiry ke backend untuk satu intent; kembalikan body JSON apa adanya.
    func inquire(_ intent: TanyaAIIntent) async throws -> Data
}

/// Satu pertanyaan pengguna. `conversationId` baru setiap "Percakapan baru".
public struct TanyaAIChatRequest: Equatable, Sendable {
    public let conversationId: String
    public let text: String

    public init(conversationId: String, text: String) {
        self.conversationId = conversationId
        self.text = text
    }
}

/// Event SSE mentah: `event:` dan isi `data:` (JSON).
public struct TanyaAIServerEvent: Equatable, Sendable {
    public let name: String
    public let data: Data

    public init(name: String, data: Data) {
        self.name = name
        self.data = data
    }
}

/// Intent dari chat service. `inquiryId` unik per inquiry; `parameters` sudah berisi
/// nilai yang diingat chat service (mis. autofill transfer dari jawaban sebelumnya).
public struct TanyaAIIntent: Equatable, Sendable, Decodable {
    public let name: String
    public let inquiryId: String
    public let parameters: [String: String]

    public init(name: String, inquiryId: String, parameters: [String: String]) {
        self.name = name
        self.inquiryId = inquiryId
        self.parameters = parameters
    }
}
