//
//  TanyaAIChatService.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 28/10/26.
//

import Foundation
import TanyaAI

/// Tiruan service chat-gateway Byon (Alamofire): gaya callback, body mentah tanpa envelope host, dan callback
/// selalu di main queue. Semua state disentuh di main queue, jadi aman dipanggil dari thread mana pun.
final class TanyaAIChatService {
    private let options: SandboxOptions
    /// Meniru blocker jaringan host: kirim tanpa internet juga dilaporkan ke halaman host.
    private let onSubmissionFailed: (Error) -> Void
    private var frames: SandboxGatewayFrames
    private var onLine: ((String) -> Void)?

    init(options: SandboxOptions, onSubmissionFailed: @escaping (Error) -> Void) {
        self.options = options
        self.onSubmissionFailed = onSubmissionFailed
        frames = SandboxGatewayFrames(seq: options.isShowingHistory ? SandboxGatewayFrames.historyLatestSeq : .zero)
    }

    func initialize(onSuccess: @escaping (Data) -> Void, onFailed: @escaping (Error) -> Void) {
        DispatchQueue.main.async { onSuccess(SandboxGatewayFrames.initialize) }
    }

    /// `--with-history`: fixture dua tanggal; selain itu percakapan kosong (sambutan tampil).
    func history(
        conversationID: String, before: String?, limit: Int,
        onSuccess: @escaping (Data) -> Void, onFailed: @escaping (Error) -> Void
    ) {
        DispatchQueue.main.async { [options] in
            guard options.isShowingHistory, let url = SandboxFixtureFile.tanyaAIHistoryDummy.url else {
                onSuccess(SandboxGatewayFrames.emptyHistory)
                return
            }
            do {
                onSuccess(try Data(contentsOf: url))
            } catch {
                onFailed(error)
            }
        }
    }

    func sendMessage(
        conversationID: String, clientMessageID: String, text: String,
        onSuccess: @escaping (Data) -> Void, onFailed: @escaping (Error) -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard !self.options.isOffline else {
                let error = URLError(.notConnectedToInternet)
                self.onSubmissionFailed(error)
                onFailed(error)
                return
            }
            guard !self.options.isRejectingSend else {
                onFailed(
                    TanyaAITransportError.response(
                        statusCode: SandboxGatewayFrames.badRequestStatus, body: SandboxGatewayFrames.badRequest
                    ))
                return
            }
            onSuccess(self.accept(text, clientMessageID: clientMessageID))
        }
    }

    /// Stream SSE tiruan: `onLine` per baris lengkap. Kembalian dipakai pemanggil untuk menutup stream,
    /// sama seperti `DataStreamRequest.cancel()` di Byon.
    func events(
        conversationID: String, lastEventID: String?,
        onLine: @escaping (String) -> Void, onComplete: @escaping (Error?) -> Void
    ) -> SandboxStreamRequest {
        DispatchQueue.main.async { [weak self] in
            self?.onLine = onLine
            onLine(SandboxGatewayFrames.connected)
        }
        return SandboxStreamRequest { [weak self] in
            DispatchQueue.main.async { self?.onLine = nil }
        }
    }
}

// MARK: - Gateway tiruan

private extension TanyaAIChatService {
    /// Pertanyaan langsung tampil di stream lalu dijawab setelah jeda, seperti gateway asli.
    func accept(_ text: String, clientMessageID: String) -> Data {
        let ack = frames.ack()
        emit(frames.message(direction: SandboxWireMessage.customer, text: text, clientMessageID: clientMessageID))
        if !options.isHoldingReply {
            DispatchQueue.main.asyncAfter(deadline: .now() + SandboxOptions.replyDelay) { [weak self] in
                guard let self else { return }
                self.emit(
                    self.frames.message(direction: SandboxWireMessage.bot, text: SandboxGatewayFrames.reply(to: text)))
                self.emit(self.frames.turnEnd())
            }
        }
        return ack
    }

    func emit(_ lines: [String]) {
        lines.forEach { onLine?($0) }
    }
}
