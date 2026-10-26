//
//  ChatViewModel.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import Foundation

/// Pemilik percakapan: membuka sesi, menjaga stream SSE tetap hidup, mengirim dan menghentikan chat,
/// serta memuat history.
@MainActor
final class ChatViewModel: ObservableObject {
    enum Phase: Equatable {
        case connecting, ready, failed
    }

    // Diubah hanya oleh ChatViewModel dan extension-nya; view hanya membaca.
    @Published
    var messages: [ChatMessage] = []
    /// Greeting dan shortcut; hanya tampil selama percakapan masih kosong.
    @Published
    var welcome: ChatWelcome?
    @Published
    var phase = Phase.connecting
    @Published
    var turn = ChatTurn.idle
    @Published
    var notice: ChatNotice?
    /// Id pesan user terakhir hasil `send` yang muncul di stream; composer lalu mengosongkan draft.
    @Published
    var deliveredQuestionId: String?
    var isMoreHistoryAvailable = false
    var sessionId: String?
    /// Satu reconnect otomatis per putus; diisi lagi setiap ada event dari stream.
    var isReconnectAllowed = true
    /// Pertanyaan yang jawabannya dihentikan; jawaban yang datang terlambat diabaikan.
    var stoppedQuestions: Set<String> = []
    var connectionTask: Task<Void, Never>?
    var streamTask: Task<Void, Never>?
    var historyTask: Task<Void, Never>?
    var turnTask: Task<Void, Never>?
    let service: TanyaAIService

    init(service: TanyaAIService) {
        self.service = service
    }

    deinit {
        connectionTask?.cancel()
        streamTask?.cancel()
        historyTask?.cancel()
        turnTask?.cancel()
    }

    /// Shortcut hanya bisa dipakai di percakapan kosong yang siap menerima chat.
    var isShortcutEnabled: Bool { phase == .ready && turn == .idle && messages.isEmpty }

    /// Dipanggil saat halaman tampil; tidak membuka sesi kedua bila sudah berjalan.
    func start() {
        guard connectionTask == nil, sessionId == nil else { return }
        connect()
    }

    /// Init → history → config (bila kosong) → buka stream. Juga dipakai tombol coba lagi.
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

    /// Muat halaman history sebelumnya saat daftar mendekati atas.
    func loadOlder() {
        guard isMoreHistoryAvailable, historyTask == nil, phase == .ready, let sessionId,
            let oldest = messages.first?.id
        else { return }
        historyTask = Task { [weak self, service] in
            let data = try? await service.history(sessionId: sessionId, before: oldest)
            self?.didLoadOlder(data)
        }
    }
}
