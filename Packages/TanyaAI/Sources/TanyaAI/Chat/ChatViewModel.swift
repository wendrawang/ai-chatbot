//
//  ChatViewModel.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import DesignKit
import Foundation

/// Pemilik percakapan: mengirim pertanyaan, mengalirkan jawaban, dan menjalankan action.
@MainActor
final class ChatViewModel: ObservableObject {
    // Diubah hanya oleh ChatViewModel dan extension streaming-nya; view hanya membaca.
    @Published
    var messages: [ChatMessage] = []
    @Published
    var isResponding = false
    let service: TanyaAIService
    let locale: Locale
    let onOpenLink: (TanyaAILink) -> Void
    var conversationId = UUID().uuidString
    var responseTask: Task<Void, Never>?

    init(service: TanyaAIService, locale: Locale, onOpenLink: @escaping (TanyaAILink) -> Void) {
        self.service = service
        self.locale = locale
        self.onOpenLink = onOpenLink
    }

    deinit {
        responseTask?.cancel()
    }

    /// True bila pertanyaan diterima (composer boleh dikosongkan).
    @discardableResult
    func send(_ text: String) -> Bool {
        let prompt = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, !isResponding else { return false }
        appendUser(prompt)
        let answerId = appendAssistant()
        stream(TanyaAIChatRequest(conversationId: conversationId, text: prompt), into: answerId)
        return true
    }

    func stop() {
        responseTask?.cancel()
        responseTask = nil
        guard let index = messages.indices.last, messages[index].role == .assistant, isResponding else { return }
        messages[index].status = nil
        if messages[index].text.isEmpty && messages[index].blocks.isEmpty {
            messages[index].text = String(resource: R.string.localizable.chatStopped, locale: locale)
        }
        isResponding = false
    }

    func perform(_ action: ActionTarget, label: String) {
        switch action.type {
        case .prompt: send(action.value)
        case .link: URL(safeLink: action.value).map { onOpenLink(TanyaAILink($0)) }
        case .intent:
            guard !isResponding else { return }
            appendUser(label)
            let answerId = appendAssistant()
            let intent = TanyaAIIntent(
                name: action.value, inquiryId: UUID().uuidString, parameters: action.parameters ?? [:])
            responseTask = Task { [weak self] in await self?.answer(intent, into: answerId) }
        }
    }

    func select(_ item: OptionsBlock.Item, blockIndex: Int, messageId: String) {
        guard let index = messages.firstIndex(where: { $0.id == messageId }), messages[index].isInteractive,
            messages[index].selections[blockIndex] == nil, !isResponding
        else { return }
        messages[index].selections[blockIndex] = item.id
        perform(item.action ?? ActionTarget(type: .prompt, value: item.label, parameters: nil), label: item.label)
    }

    func openLink(_ url: URL) {
        onOpenLink(TanyaAILink(url))
    }

    /// Kembali ke welcome dengan sesi baru; stream yang berjalan dihentikan.
    func startNewConversation() {
        responseTask?.cancel()
        responseTask = nil
        isResponding = false
        messages = []
        conversationId = UUID().uuidString
    }
}

// MARK: - Helpers

extension ChatViewModel {
    func appendUser(_ text: String) {
        for index in messages.indices where messages[index].isInteractive { messages[index].isInteractive = false }
        messages.append(
            ChatMessage(id: UUID().uuidString, role: .user, createdAt: Date(), isDateVisible: isNewDay, text: text))
    }

    func appendAssistant() -> String {
        let message = ChatMessage(
            id: UUID().uuidString, role: .assistant, createdAt: Date(), isDateVisible: isNewDay,
            status: String(resource: R.string.localizable.chatThinking, locale: locale)
        )
        messages.append(message)
        isResponding = true
        return message.id
    }

    private var isNewDay: Bool {
        guard let last = messages.last else { return true }
        return !Calendar.current.isDateInToday(last.createdAt)
    }
}
