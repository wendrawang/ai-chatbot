//
//  ChatAttachmentFileTests.swift
//  TanyaAI
//
//  Created by Wendra on 27/11/26.
//

import Foundation
import Testing

@testable import TanyaAI

/// Nama, keterangan format, dan MIME lampiran dibaca dari nama file salinannya.
struct ChatAttachmentFileTests {
    @Test(arguments: [
        ("Slip.pdf", "PDF", "application/pdf"),
        ("IMG_0001.heic", "HEIC", "image/heic"),
        ("foto.JPG", "JPG", "image/jpeg"),
        ("data.zzz", "ZZZ", ChatWire.fallbackMIMEType)
    ])
    func formatAndMIMEFollowTheExtension(name: String, format: String, mimeType: String) {
        let file = ChatAttachmentFile(url: URL(fileURLWithPath: "/tmp/salinan").appendingPathComponent(name))
        #expect(file.name == name)
        #expect(file.formatLabel == format)
        #expect(file.mimeType == mimeType)
    }
}
