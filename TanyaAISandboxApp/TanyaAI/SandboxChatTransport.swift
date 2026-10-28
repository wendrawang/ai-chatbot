//
//  SandboxChatTransport.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 28/10/26.
//

import Foundation
import TanyaAI

/// Gateway tiruan di memori, pengganti service chat ICT milik host. Pertanyaan diterima (ack), lalu
/// pertanyaan dan jawaban bot dikirim lewat stream yang terbuka, diakhiri `turn_end`.
/// `--offline` gagal kirim tanpa internet (blocker host), `--reject-send` menolak kirim, `--hold-reply` tidak menjawab,
/// `--with-history` memuat history fixture.
@MainActor
final class SandboxChatTransport: TanyaAIChatTransport {
    private let options: SandboxOptions
    private let onSubmissionFailed: (Error) -> Void
    private var frames: SandboxGatewayFrames
    private var continuation: AsyncThrowingStream<String, Error>.Continuation?

    init(options: SandboxOptions, onSubmissionFailed: @escaping (Error) -> Void) {
        self.options = options
        self.onSubmissionFailed = onSubmissionFailed
        frames = SandboxGatewayFrames(seq: options.isShowingHistory ? SandboxGatewayFrames.historyLatestSeq : .zero)
    }

    func initialize() async throws -> Data {
        SandboxGatewayFrames.initialize
    }

    /// `--with-history`: fixture dua tanggal; selain itu percakapan kosong (sambutan tampil).
    func history(conversationID: String, before: String?, limit: Int) async throws -> Data {
        guard options.isShowingHistory, let url = SandboxFixtureFile.tanyaAIHistoryDummy.url else {
            return SandboxGatewayFrames.emptyHistory
        }
        return try Data(contentsOf: url)
    }

    func sendMessage(conversationID: String, clientMessageID: String, text: String) async throws -> Data {
        guard !options.isOffline else {
            let error = URLError(.notConnectedToInternet)
            onSubmissionFailed(error)
            throw error
        }
        guard !options.isRejectingSend else {
            throw TanyaAITransportError.response(
                statusCode: SandboxGatewayFrames.badRequestStatus, body: SandboxGatewayFrames.badRequest
            )
        }
        let ack = frames.ack()
        emit(frames.message(direction: SandboxWireMessage.customer, text: text, clientMessageID: clientMessageID))
        if !options.isHoldingReply {
            scheduleReply(to: text)
        }
        return ack
    }

    nonisolated func events(conversationID: String, lastEventID: String?) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(SandboxGatewayFrames.connected)
            Task { @MainActor [weak self] in self?.continuation = continuation }
        }
    }
}

// MARK: - Helpers

private extension SandboxChatTransport {
    func emit(_ lines: [String]) {
        lines.forEach { continuation?.yield($0) }
    }

    func scheduleReply(to question: String) {
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(SandboxOptions.replyDelay * Double(NSEC_PER_SEC)))
            guard let self else { return }
            self.emit(
                self.frames.message(direction: SandboxWireMessage.bot, text: SandboxGatewayFrames.reply(to: question)))
            self.emit(self.frames.turnEnd())
        }
    }
}
