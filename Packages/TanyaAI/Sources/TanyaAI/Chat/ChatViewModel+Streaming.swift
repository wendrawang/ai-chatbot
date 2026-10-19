//
//  ChatViewModel+Streaming.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import DesignKit
import Foundation

/// Alur jawaban: SSE (status, teks, blok, intent) lalu inquiry BE bila ada intent.
extension ChatViewModel {
    func stream(_ request: TanyaAIChatRequest, into answerId: String) {
        responseTask = Task { [weak self, service] in
            var intent: TanyaAIIntent?
            do {
                for try await serverEvent in service.streamChat(request) {
                    guard let self, let event = ChatEvent(serverEvent) else { continue }
                    if case .failure(let isRetryable) = event {
                        self.fail(answerId, isRetryable: isRetryable, prompt: request.text)
                        return
                    }
                    if case .intent(let received) = event { intent = received }
                    self.apply(event, to: answerId)
                }
            } catch {
                // Stop/tutup halaman membatalkan task; jangan menimpa jawaban berikutnya.
                guard !Task.isCancelled else { return }
                self?.fail(answerId, isRetryable: true, prompt: request.text)
                return
            }
            guard !Task.isCancelled else { return }
            guard let intent else {
                self?.finish(answerId)
                return
            }
            await self?.answer(intent, into: answerId)
        }
    }

    /// Inquiry BE untuk intent, lalu terjemahkan hasilnya lewat mapping intent itu.
    func answer(_ intent: TanyaAIIntent, into answerId: String) async {
        do {
            let data = try await service.inquire(intent)
            guard !Task.isCancelled else { return }
            guard let mapping = IntentMappings.mapping(for: intent.name) else {
                update(answerId) { $0.text = String(resource: R.string.localizable.chatUnsupported, locale: locale()) }
                finish(answerId)
                return
            }
            let blocks = try mapping.blocks(from: data, locale: locale())
            guard !Task.isCancelled else { return }
            update(answerId) { $0.blocks += blocks }
            finish(answerId)
        } catch {
            guard !Task.isCancelled else { return }
            fail(answerId, isRetryable: false, prompt: nil)
        }
    }

    func apply(_ event: ChatEvent, to answerId: String) {
        switch event {
        case .status(let text): update(answerId) { $0.status = text }
        case .delta(let text):
            update(answerId) {
                $0.text += text; $0.status = nil
            }
        case .blocks(let blocks):
            update(answerId) {
                $0.blocks += blocks; $0.status = nil
            }
        case .start, .intent, .end, .failure: break
        }
    }
}

// MARK: - Helpers

private extension ChatViewModel {
    func update(_ answerId: String, change: (inout ChatMessage) -> Void) {
        guard let index = messages.lastIndex(where: { $0.id == answerId }) else { return }
        change(&messages[index])
    }

    func finish(_ answerId: String) {
        update(answerId) { $0.status = nil }
        isResponding = false
        responseTask = nil
    }

    /// Pesan gagal yang ramah; retry mengirim ulang pertanyaan yang sama.
    func fail(_ answerId: String, isRetryable: Bool, prompt: String?) {
        guard isResponding else { return }
        update(answerId) { message in
            message.text = String(resource: R.string.localizable.chatError, locale: locale())
            guard isRetryable, let prompt else { return }
            let retry = ActionItem(
                label: String(resource: R.string.localizable.chatRetry, locale: locale()), style: .chip,
                action: ActionTarget(type: .prompt, value: prompt, parameters: nil)
            )
            message.blocks = [.actions([retry])]
        }
        finish(answerId)
    }
}
