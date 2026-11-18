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

    /// Salinan galeri dibuang bersama foldernya; folder yang masih berisi file lain tetap ada.
    @Test
    func discardRemovesTheFileAndOnlyAnEmptyFolder() throws {
        let manager = FileManager.default
        let source = manager.temporaryDirectory.appendingPathComponent("dokumen.pdf")
        try Data("pdf".utf8).write(to: source)
        defer { try? manager.removeItem(at: source) }
        let copy = try manager.copyChatAttachment(from: source)
        manager.discardChatAttachment(at: copy)
        #expect(!manager.fileExists(atPath: copy.deletingLastPathComponent().path))
        let shared = try manager.copyChatAttachment(from: source)
        let sibling = shared.deletingLastPathComponent().appendingPathComponent("lain.pdf")
        try Data("pdf".utf8).write(to: sibling)
        defer { try? manager.removeItem(at: shared.deletingLastPathComponent()) }
        manager.discardChatAttachment(at: shared)
        #expect(!manager.fileExists(atPath: shared.path))
        #expect(manager.fileExists(atPath: sibling.path))
    }
}
