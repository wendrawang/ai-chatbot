//
//  TanyaAIUseCaseChatTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 28/10/26.
//

import Foundation
import TanyaAI
import Testing

@testable import Tanya_AI_Sandbox

/// UseCase sebagai `TanyaAIChatTransport`: callback service dibungkus continuation dan stream.
@MainActor
struct TanyaAIUseCaseChatTests {
    @Test
    func acceptedQuestionComesBackOnTheStreamWithAReplyAndTurnEnd() async throws {
        let useCase = makeUseCase()
        var lines = useCase.events(conversationID: "c", lastEventID: nil).makeAsyncIterator()
        #expect(try await lines.next() == ": connected")
        _ = try await useCase.sendMessage(conversationID: "c", clientMessageID: "c-1", text: "Cek Portfolio saya")
        var received: [String] = []
        while received.filter({ $0.hasPrefix("event:") }).count < 3, let line = try await lines.next() {
            received.append(line)
        }
        #expect(received.filter { $0.hasPrefix("event:") } == ["event: message", "event: message", "event: turn_end"])
        #expect(received.filter { $0.contains("Cek Portfolio saya") }.count == 2)
    }

    @Test
    func initAndHistoryReturnTheRawGatewayBodies() async throws {
        let useCase = makeUseCase()
        #expect(try await useCase.initialize() == SandboxGatewayFrames.initialize)
        #expect(
            try await useCase.history(conversationID: "c", before: nil, limit: 30) == SandboxGatewayFrames.emptyHistory)
    }

    @Test
    func rejectedSendThrowsANonRetryableBadRequest() async {
        let useCase = makeUseCase(arguments: ["--reject-send"])
        await #expect(throws: TanyaAITransportError.self) {
            try await useCase.sendMessage(conversationID: "c", clientMessageID: "c-1", text: "x")
        }
    }

    @Test
    func offlineSendTellsTheHostBlocker() async {
        let useCase = makeUseCase(arguments: ["--offline"])
        var failures: [Error] = []
        useCase.callback.onSubmissionFailed = { failures.append($0) }
        await #expect(throws: URLError.self) {
            try await useCase.sendMessage(conversationID: "c", clientMessageID: "c-1", text: "x")
        }
        #expect(failures.count == 1)
    }

    /// Stream ditutup (halaman ditutup → `onTermination` → `cancel()`): baris berikutnya tidak dikirim lagi.
    @Test
    func cancelledStreamNoLongerReceivesLines() async throws {
        let useCase = makeUseCase(arguments: ["--hold-reply"])
        var received: [String] = []
        let request = useCase.chatService.events(
            conversationID: "c", lastEventID: nil, onLine: { received.append($0) }, onComplete: { _ in }
        )
        await waitUntil { received == [": connected"] }
        request.cancel()
        _ = try await useCase.sendMessage(conversationID: "c", clientMessageID: "c-1", text: "x")
        #expect(received == [": connected"])
    }
}

// MARK: - Helpers

private extension TanyaAIUseCaseChatTests {
    func makeUseCase(arguments: [String] = []) -> TanyaAIUseCase {
        TanyaAIUseCase(options: SandboxOptions(arguments: arguments))
    }
}
