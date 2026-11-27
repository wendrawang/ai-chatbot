//
//  ChatAttachmentFile+Upload.swift
//  TanyaAI
//
//  Created by Wendra on 27/11/26.
//

import Foundation

extension ChatAttachmentFile {
    /// Isi file sebagai base64 untuk body upload. Dibaca dan di-encode di luar main thread karena file 10 MB menjadi
    /// sekitar 13,3 MB teks; UI tetap responsif selama proses ini.
    func encodedForUpload() async throws -> TanyaAIAttachment {
        let source = url
        let base64Data = try await Task.detached(priority: .userInitiated) {
            try Data(contentsOf: source).base64EncodedString()
        }.value
        return TanyaAIAttachment(fileName: name, mimeType: mimeType, base64Data: base64Data)
    }
}
