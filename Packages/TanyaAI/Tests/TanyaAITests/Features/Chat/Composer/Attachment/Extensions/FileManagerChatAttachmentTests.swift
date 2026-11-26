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
/// Serial karena satu test membandingkan isi folder sementara sebelum dan sesudah menyalin.
@Suite(.serialized)
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

    /// Gagal menyalin tidak meninggalkan folder kosong, karena pemanggil tidak menerima URL untuk dibersihkan.
    @Test
    func missingSourceThrowsWithoutLeavingAFolder() throws {
        let manager = FileManager.default
        let missing = manager.temporaryDirectory.appendingPathComponent("tidak-ada.pdf")
        let before = try manager.contentsOfDirectory(atPath: manager.temporaryDirectory.path)
        #expect(throws: (any Error).self) { try manager.copyChatAttachment(from: missing) }
        let after = try manager.contentsOfDirectory(atPath: manager.temporaryDirectory.path)
        #expect(Set(after) == Set(before))
    }

    /// Tepat di batas masih diterima; satu byte di atasnya ditolak sebelum disalin, tanpa meninggalkan folder.
    @Test
    func filesAboveTheLimitAreRejectedBeforeCopying() throws {
        let manager = FileManager.default
        let limit = FileManager.chatAttachmentByteLimit
        let accepted = try Self.sparseFile(named: "batas.pdf", size: limit)
        let rejected = try Self.sparseFile(named: "besar.pdf", size: limit + 1)
        defer {
            try? manager.removeItem(at: accepted)
            try? manager.removeItem(at: rejected)
        }
        let copy = try manager.copyChatAttachment(from: accepted)
        manager.discardChatAttachment(at: copy)
        let before = try manager.contentsOfDirectory(atPath: manager.temporaryDirectory.path)
        #expect(throws: ChatAttachmentRejection.tooLarge) { try manager.copyChatAttachment(from: rejected) }
        let after = try manager.contentsOfDirectory(atPath: manager.temporaryDirectory.path)
        #expect(Set(after) == Set(before))
    }

    /// Hasil salinan tiba di main thread: file ke pemilih, penolakan ukuran ke snackbar.
    @Test
    @MainActor
    func copiesAndRejectionsArriveOnTheMainThread() async throws {
        let manager = FileManager.default
        let small = try Self.sparseFile(named: "kecil.pdf", size: 1_024)
        let large = try Self.sparseFile(named: "besar.png", size: FileManager.chatAttachmentByteLimit + 1)
        defer {
            try? manager.removeItem(at: small)
            try? manager.removeItem(at: large)
        }
        let copied = try await Self.deliver(small).get()
        defer { manager.discardChatAttachment(at: copied) }
        #expect(copied.lastPathComponent == "kecil.pdf")
        #expect(await Self.deliver(large) == .failure(.tooLarge))
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

extension FileManagerChatAttachmentTests {
    /// Hasil `deliverChatAttachmentCopy` yang dipanggil dari background, seperti picker sistem.
    static func deliver(_ source: URL) async -> Result<URL, ChatAttachmentRejection> {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                FileManager.default.deliverChatAttachmentCopy(
                    of: source,
                    onPick: { file in
                        #expect(Thread.isMainThread)
                        continuation.resume(returning: .success(file))
                    },
                    onReject: { rejection in
                        #expect(Thread.isMainThread)
                        continuation.resume(returning: .failure(rejection))
                    }
                )
            }
        }
    }

    /// File sparse sebesar `size` byte di folder sementara: ukurannya terbaca tanpa menulis isi sebanyak itu.
    static func sparseFile(named name: String, size: Int) throws -> URL {
        let file = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        FileManager.default.createFile(atPath: file.path, contents: nil)
        let handle = try FileHandle(forWritingTo: file)
        defer { try? handle.close() }
        try handle.truncate(atOffset: UInt64(size))
        return file
    }
}
