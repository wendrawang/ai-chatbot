//
//  TanyaAIAttachment.swift
//  TanyaAI
//
//  Created by Wendra on 27/11/26.
//

/// Satu lampiran nasabah yang siap dikirim host lewat `TanyaAIChatTransport.sendAttachment`. Isi file sudah
/// di-encode base64 oleh TanyaAI di luar main thread; host cukup memasukkannya ke body request.
public struct TanyaAIAttachment: Equatable, Sendable {
    /// Nama file asli pilihan nasabah, mis. `Slip.pdf`.
    public let fileName: String
    /// Mis. `application/pdf` atau `image/jpeg`.
    public let mimeType: String
    /// Isi file sebagai base64 standar tanpa pemisah baris.
    public let base64Data: String

    public init(fileName: String, mimeType: String, base64Data: String) {
        self.fileName = fileName
        self.mimeType = mimeType
        self.base64Data = base64Data
    }
}
