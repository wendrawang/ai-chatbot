//
//  ChatViewModel.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import Foundation

/// Pemilik percakapan: membuka sesi, menjaga stream SSE tetap hidup, mengirim chat, dan memuat history.
@MainActor
final class ChatViewModel: ObservableObject {
    enum Phase: Equatable {
        case connecting, ready, failed
    }

    // Diubah hanya oleh ChatViewModel dan extension-nya; view hanya membaca.
    @Published
    var messages: [ChatMessage] = []
    @Published
    var phase = Phase.connecting
    /// Id chat user yang sudah terkirim dan masih menunggu jawaban.
    @Published
    var pendingReplies: Set<String> = []
    var isMoreHistoryAvailable = false
    var sessionId: String?
    /// Satu reconnect otomatis per putus; diisi lagi setiap ada event dari stream.
    var isReconnectAllowed = true
    var connectionTask: Task<Void, Never>?
    var streamTask: Task<Void, Never>?
    var historyTask: Task<Void, Never>?
    let service: TanyaAIService

    init(service: TanyaAIService) {
        self.service = service
    }

    deinit {
        connectionTask?.cancel()
        streamTask?.cancel()
        historyTask?.cancel()
    }

    var isReplying: Bool { !pendingReplies.isEmpty }

    /// Dipanggil saat halaman tampil; tidak membuka sesi kedua bila sudah berjalan.
    func start() {
        guard connectionTask == nil, sessionId == nil else { return }
        connect()
    }

    /// Init → history → buka stream. Juga dipakai tombol coba lagi.
    func connect() {
        connectionTask?.cancel()
        streamTask?.cancel()
        phase = .connecting
        connectionTask = Task { [weak self] in await self?.establish() }
    }

    func retry() {
        isReconnectAllowed = true
        connect()
    }

    /// True bila chat diterima (composer dikosongkan). Jawaban datang lewat stream.
    func send(_ text: String) -> Bool {
        let question = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, phase == .ready, let sessionId else { return false }
        let pending = ChatMessage.pendingQuestion(question)
        messages.append(pending)
        deliver(pending, sessionId: sessionId)
        return true
    }

    /// Kirim ulang chat yang gagal terkirim.
    func resend(_ messageId: String) {
        guard let index = messages.firstIndex(where: { $0.id == messageId }), messages[index].delivery == .failed,
            let sessionId
        else { return }
        messages[index].delivery = .sending
        deliver(messages[index], sessionId: sessionId)
    }

    /// Muat halaman history sebelumnya saat daftar mendekati atas.
    func loadOlder() {
        guard isMoreHistoryAvailable, historyTask == nil, phase == .ready, let sessionId,
            let oldest = messages.first(where: { $0.delivery == .sent })?.id
        else { return }
        historyTask = Task { [weak self, service] in
            let data = try? await service.history(sessionId: sessionId, before: oldest)
            self?.didLoadOlder(data)
        }
    }
}
