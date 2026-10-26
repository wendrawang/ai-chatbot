//
//  ChatViewModel+Connection.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import Foundation

/// Sesi, stream SSE, reconnect, dan penggabungan pesan.
extension ChatViewModel {
    func establish() async {
        do {
            let session = try ChatPayload.decode(SessionPayload.self, from: await service.start())
            let page = try ChatPayload.decode(
                HistoryPayload.self, from: await service.history(sessionId: session.sessionId, before: nil))
            let isFirstConnection = sessionId == nil && messages.isEmpty
            let welcome = await loadWelcome(isEmpty: page.messages.isEmpty, sessionId: session.sessionId)
            guard !Task.isCancelled else { return }
            sessionId = session.sessionId
            merge(page.messages.map(ChatMessage.init))
            if isFirstConnection { isMoreHistoryAvailable = page.isMoreAvailable }
            if let welcome { self.welcome = welcome }
            reconcileTurn()
            phase = .ready
            openStream(sessionId: session.sessionId)
        } catch {
            guard !Task.isCancelled else { return }
            phase = .failed
        }
        connectionTask = nil
    }

    /// Config hanya untuk percakapan kosong. Gagal memuat config tidak menghalangi chat.
    func loadWelcome(isEmpty: Bool, sessionId: String) async -> ChatWelcome? {
        guard isEmpty, messages.isEmpty, welcome == nil,
            let data = try? await service.config(sessionId: sessionId),
            let payload = try? ChatPayload.decode(ConfigPayload.self, from: data)
        else { return nil }
        return ChatWelcome(payload)
    }

    func openStream(sessionId: String) {
        let stream = service.events(sessionId: sessionId)
        streamTask = Task { [weak self] in
            do {
                for try await event in stream { self?.receive(event) }
            } catch {
                // Error stream sama dengan koneksi putus; ditangani di bawah.
            }
            guard !Task.isCancelled else { return }
            self?.streamDidEnd()
        }
    }

    func receive(_ event: TanyaAIServerEvent) {
        switch ServerEventName(rawValue: event.name) {
        case .message:
            isReconnectAllowed = true
            guard let payload = try? ChatPayload.decode(MessagePayload.self, from: event.data) else { return }
            let message = ChatMessage(payload)
            if message.role == .assistant, let replyTo = message.replyTo, stoppedQuestions.contains(replyTo) { return }
            merge([message])
            advanceTurn(with: message)
        case .heartbeat:
            isReconnectAllowed = true
        case .error, .none:
            // Event error diikuti penutupan stream oleh BE; event tak dikenal diabaikan.
            break
        }
    }

    /// Stream putus: init ulang sekali (history mengisi pesan yang terlewat), lalu menyerah ke tombol coba lagi.
    func streamDidEnd() {
        streamTask = nil
        guard isReconnectAllowed else {
            phase = .failed
            return
        }
        isReconnectAllowed = false
        connect()
    }

    func didLoadOlder(_ data: Data?) {
        historyTask = nil
        guard let data, let page = try? ChatPayload.decode(HistoryPayload.self, from: data) else { return }
        isMoreHistoryAvailable = page.isMoreAvailable
        merge(page.messages.map(ChatMessage.init))
    }

    /// Tambah pesan yang belum ada (berdasarkan id), lalu urutkan kronologis tanpa mengacak waktu yang sama.
    func merge(_ incoming: [ChatMessage]) {
        let known = Set(messages.map(\.id))
        let fresh = incoming.filter { !known.contains($0.id) }
        guard !fresh.isEmpty else { return }
        messages = (messages + fresh).enumerated()
            .sorted { ($0.element.createdAt, $0.offset) < ($1.element.createdAt, $1.offset) }
            .map(\.element)
    }
}
