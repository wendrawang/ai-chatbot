//
//  ChatAttachmentFile.swift
//  TanyaAI
//
//  Created by Wendra on 27/11/26.
//

import Foundation
import UniformTypeIdentifiers

/// Salinan lokal file pilihan nasabah di folder sementara aplikasi (lihat `FileManager.copyChatAttachment`).
/// Salinan ini yang dikirim dan dibuka di "Lihat Detail", jadi detail tidak perlu mengunduh dari server.
struct ChatAttachmentFile: Equatable, Sendable {
    let url: URL

    /// Nama file asli, mis. `Slip.pdf`.
    var name: String { url.lastPathComponent }

    /// Format dari ekstensi untuk keterangan kartu, mis. `PDF` atau `JPG`.
    var formatLabel: String { url.pathExtension.uppercased() }

    var mimeType: String {
        UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? ChatWire.fallbackMIMEType
    }
}
