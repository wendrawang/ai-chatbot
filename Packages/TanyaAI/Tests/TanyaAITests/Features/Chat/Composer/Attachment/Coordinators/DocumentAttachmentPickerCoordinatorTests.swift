//
//  DocumentAttachmentPickerCoordinatorTests.swift
//  TanyaAI
//
//  Created by Wendra on 26/11/26.
//

import Foundation
import Testing
import UIKit

@testable import TanyaAI

/// File dari aplikasi Files: sheet ditutup dulu, lalu salinan atau penolakan ukuran tiba di main thread.
/// Serial karena memakai file sementara bernama tetap.
@MainActor
@Suite(.serialized)
struct DocumentAttachmentPickerCoordinatorTests {
    @Test
    func aFileWithinTheLimitIsCopiedForTheSender() async throws {
        let source = try FileManagerChatAttachmentTests.sparseFile(named: "surat.pdf", size: 1_024)
        defer { try? FileManager.default.removeItem(at: source) }
        let copy = try await pick(source).get()
        defer { FileManager.default.discardChatAttachment(at: copy) }
        #expect(copy != source)
        #expect(copy.lastPathComponent == source.lastPathComponent)
    }

    @Test
    func aFileAboveTheLimitIsRejected() async throws {
        let size = FileManager.chatAttachmentByteLimit + 1
        let source = try FileManagerChatAttachmentTests.sparseFile(named: "video.pdf", size: size)
        defer { try? FileManager.default.removeItem(at: source) }
        #expect(await pick(source) == .failure(.tooLarge))
    }
}

// MARK: - Helpers

private extension DocumentAttachmentPickerCoordinatorTests {
    func pick(_ source: URL) async -> Result<URL, ChatAttachmentRejection> {
        var isDismissed = false
        let result = await withCheckedContinuation { continuation in
            let coordinator = DocumentAttachmentPickerCoordinator(
                onPick: { file in
                    #expect(Thread.isMainThread)
                    continuation.resume(returning: Result<URL, ChatAttachmentRejection>.success(file))
                },
                onReject: { rejection in
                    #expect(Thread.isMainThread)
                    continuation.resume(returning: .failure(rejection))
                },
                onDismiss: { isDismissed = true }
            )
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
            coordinator.documentPicker(picker, didPickDocumentsAt: [source])
        }
        #expect(isDismissed)
        return result
    }
}
