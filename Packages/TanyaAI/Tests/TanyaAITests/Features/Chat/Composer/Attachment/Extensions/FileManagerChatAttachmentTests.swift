//
//  FileManagerChatAttachmentTests.swift
//  TanyaAI
//
//  Created by Wendra on 18/11/26.
//

import Foundation
import Testing

@testable import TanyaAI

/// File dari galeri disalin sebelum sistem menghapusnya; nama asli tetap dan salinan tidak saling menimpa.
struct FileManagerChatAttachmentTests {
    @Test
    func copiesKeepTheNameAndContentWithoutOverwritingEachOther() throws {
        let manager = FileManager.default
        let source = manager.temporaryDirectory.appendingPathComponent("IMG_0001.heic")
        try Data("foto".utf8).write(to: source)
        defer { try? manager.removeItem(at: source) }
        let first = try manager.copyChatAttachment(from: source)
        let second = try manager.copyChatAttachment(from: source)
        defer {
            try? manager.removeItem(at: first.deletingLastPathComponent())
            try? manager.removeItem(at: second.deletingLastPathComponent())
        }
        #expect(first.lastPathComponent == "IMG_0001.heic")
        #expect(first != second)
        #expect(try Data(contentsOf: first) == Data("foto".utf8))
        #expect(manager.fileExists(atPath: second.path))
    }

    @Test
    func missingSourceThrows() {
        let missing = FileManager.default.temporaryDirectory.appendingPathComponent("tidak-ada.pdf")
        #expect(throws: (any Error).self) { try FileManager.default.copyChatAttachment(from: missing) }
    }
}
