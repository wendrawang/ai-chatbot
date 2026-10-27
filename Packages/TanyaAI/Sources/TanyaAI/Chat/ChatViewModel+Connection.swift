//
//  ChatViewModel+Connection.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import Foundation

/// Sesi, stream SSE, reconnect, dan penggabungan pesan.
extension ChatViewModel {
    func didConnect(_ start: ChatSessionStart) {
        connectionTask = nil
        let isFirstConnection = sessionId == nil && messages.isEmpty
        sessionId = start.sessionId
        let fresh = merge(start.page.messages.map(ChatMessage.init))
        if isFirstConnection { isMoreHistoryAvailable = start.page.isMoreAvailable }
        if let welcome = start.welcome { self.welcome = welcome }
        reconcileTurn(with: fresh)
        phase = .ready
        openStream(sessionId: start.sessionId)
    }

    func didFailConnecting() {
        connectionTask = nil
        phase = .failed
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
            // Hanya pesan yang benar-benar baru yang memajukan giliran; replay event diabaikan.
            for message in merge([ChatMessage(payload)]) { advanceTurn(with: message) }
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

    /// Tambah pesan yang belum ada (berdasarkan id) dan bukan jawaban yang sudah dihentikan, dari stream
    /// maupun history. Mengembalikan pesan yang benar-benar ditambahkan.
    @discardableResult
    func merge(_ incoming: [ChatMessage]) -> [ChatMessage] {
        let known = Set(messages.map(\.id))
        let fresh = incoming.filter { !known.contains($0.id) && !isStoppedAnswer($0) }
        guard !fresh.isEmpty else { return [] }
        let isAppending = messages.last.map { last in fresh.allSatisfy { $0.createdAt >= last.createdAt } } ?? true
        if isAppending, Self.isChronological(fresh) {
            // Jalur umum (pesan baru dari stream): cukup ditambahkan di akhir tanpa mengurutkan ulang.
            messages += fresh
        } else {
            // History lama atau urutan acak: urutkan kronologis tanpa mengacak waktu yang sama.
            messages = (messages + fresh).enumerated()
                .sorted { ($0.element.createdAt, $0.offset) < ($1.element.createdAt, $1.offset) }
                .map(\.element)
        }
        return fresh
    }

    func isStoppedAnswer(_ message: ChatMessage) -> Bool {
        message.role == .assistant && message.replyTo.map(stoppedQuestions.contains) == true
    }

    static func isChronological(_ messages: [ChatMessage]) -> Bool {
        zip(messages, messages.dropFirst()).allSatisfy { $0.createdAt <= $1.createdAt }
    }
}
