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
            guard !Task.isCancelled else { return }
            let isFirstConnection = sessionId == nil && messages.isEmpty
            sessionId = session.sessionId
            merge(page.messages.map(ChatMessage.init))
            if isFirstConnection { isMoreHistoryAvailable = page.isMoreAvailable }
            phase = .ready
            openStream(sessionId: session.sessionId)
        } catch {
            guard !Task.isCancelled else { return }
            phase = .failed
        }
        connectionTask = nil
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
            if let replyTo = payload.replyTo { pendingReplies.remove(replyTo) }
            merge([ChatMessage(payload)])
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

    func deliver(_ question: ChatMessage, sessionId: String) {
        Task { [weak self, service] in
            do {
                let data = try await service.send(question.text, sessionId: sessionId)
                let stored = try ChatPayload.decode(MessagePayload.self, from: data)
                self?.didDeliver(pendingId: question.id, stored: ChatMessage(stored))
            } catch {
                self?.didFailDelivery(pendingId: question.id)
            }
        }
    }

    func didDeliver(pendingId: String, stored: ChatMessage) {
        guard let index = messages.firstIndex(where: { $0.id == pendingId }) else { return }
        messages[index] = stored
        // Jawaban bisa saja tiba lebih dulu daripada konfirmasi kirim.
        if !messages.contains(where: { $0.replyTo == stored.id }) { pendingReplies.insert(stored.id) }
    }

    func didFailDelivery(pendingId: String) {
        guard let index = messages.firstIndex(where: { $0.id == pendingId }) else { return }
        messages[index].delivery = .failed
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
