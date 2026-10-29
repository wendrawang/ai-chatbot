//
//  TanyaAIBridge.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import Combine
import Foundation

/// Jembatan host ↔ TanyaAI yang hidup selama halaman terbuka. Host membuatnya sekali (misalnya di view model
/// milik `@StateObject` destination) bersama `TanyaAIChatTransport`, lalu memberikannya ke `TanyaAIHost`.
/// TanyaAI yang menyambung (init → history → SSE), menyambung ulang, dan menggabungkan pesan.
@MainActor
public final class TanyaAIBridge: ObservableObject {
    /// Urut `seq` naik; pesan nasabah juga baru muncul setelah datang lewat stream, bukan saat dikirim.
    @Published
    private(set) var messages: [ChatMessage] = []
    /// Pertanyaan yang sedang ditunggu jawabannya (lihat `ChatTurn`).
    @Published
    private(set) var turn = ChatTurn()
    /// True setelah history pertama selesai; sebelum itu halaman menampilkan loading, bukan sambutan.
    @Published
    private(set) var isHistoryLoaded = false
    @Published
    var connection = ChatConnection.connecting
    /// Percakapan dari `/chat/init` terakhir; nil sebelum init pertama berhasil.
    var conversationID: String?
    /// `id` event SSE terbesar yang sudah diterima (termasuk `turn_end`), bagian dari `Last-Event-ID`.
    var eventCursor: Int?
    /// Loop sambungan yang sedang berjalan; dibatalkan saat sesi habis agar stream yang terbuka ikut ditutup.
    var connectionTask: Task<Void, Never>?
    let transport: TanyaAIChatTransport
    let onSessionExpired: (() -> Void)?
    let onConnectionFailed: ((Error) -> Void)?
    let onSendFailed: ((Error) -> Void)?
    let sleep: (TimeInterval) async throws -> Void

    /// `onSessionExpired` dipanggil sekali saat gateway menjawab 401 (sesi OMNI habis); stream tidak dibuka lagi.
    /// `onConnectionFailed` dipanggil sekali saat error yang tidak bisa di-retry (`retryable:false`) menghentikan
    /// sambungan; host menampilkan error sesuai polanya. Error berupa `TanyaAITransportError` dari transport.
    /// `onSendFailed` dipanggil setiap kirim pesan gagal selain 401 (mis. 409 `turn_locked`, 429, tanpa koneksi);
    /// draft tetap di composer, stream tidak terpengaruh, dan host yang menampilkan pesan error-nya.
    public convenience init(
        transport: TanyaAIChatTransport, onSessionExpired: (() -> Void)? = nil,
        onConnectionFailed: ((Error) -> Void)? = nil, onSendFailed: ((Error) -> Void)? = nil
    ) {
        self.init(
            transport: transport, onSessionExpired: onSessionExpired, onConnectionFailed: onConnectionFailed,
            onSendFailed: onSendFailed, sleep: ChatBackoff.sleep(seconds:)
        )
    }

    /// `sleep` disuntikkan test agar jeda reconnect instan.
    init(
        transport: TanyaAIChatTransport, onSessionExpired: (() -> Void)?,
        onConnectionFailed: ((Error) -> Void)? = nil, onSendFailed: ((Error) -> Void)? = nil,
        sleep: @escaping (TimeInterval) async throws -> Void
    ) {
        self.transport = transport
        self.onSessionExpired = onSessionExpired
        self.onConnectionFailed = onConnectionFailed
        self.onSendFailed = onSendFailed
        self.sleep = sleep
    }

    /// Sejak kirim sampai `turn_end` pertanyaan itu; tombol kirim menjadi titik bergerak dan shortcut nonaktif.
    var isAwaitingReply: Bool { turn.isAwaiting }

    /// Replay stream dimulai setelah pesan atau event terakhir yang sudah diterima.
    var lastEventID: String? {
        [messages.latestSeq, eventCursor].compactMap { $0 }.max().map(String.init)
    }

    /// Loading hanya selama pembukaan pertama masih berjalan; gagal permanen atau sesi habis menghentikannya.
    var isLoadingHistory: Bool { !isHistoryLoaded && connection == .connecting }

    /// Sambutan hanya untuk percakapan kosong; pesan pertama (dari stream) langsung menggantikannya.
    var isWelcomeVisible: Bool { isHistoryLoaded && messages.isEmpty }

    /// Bisa mengirim setelah init berhasil, juga selama menyambung ulang; tidak setelah ditutup atau sesi habis.
    var isReady: Bool {
        conversationID != nil && connection != .closed && connection != .expired
    }

    /// Satu pertanyaan per waktu: selama menunggu jawaban, chat baru ditolak tanpa diteruskan ke host.
    /// True bila gateway menerima pesan (ack 202); false mempertahankan draft di composer.
    func send(_ text: String) async -> Bool {
        guard !isAwaitingReply, isReady, let conversationID else { return false }
        // Penanda pertanyaan ini: respons yang datang setelah turn berganti tidak mengubah turn yang baru.
        let clientMessageID = UUID().uuidString
        turn.start(clientMessageID: clientMessageID)
        do {
            let data = try await transport.sendMessage(
                conversationID: conversationID, clientMessageID: clientMessageID, text: text
            )
            let ack = try? JSONDecoder.wire.decode(WireEnvelope<WireSendAck>.self, from: data).data
            turn.accept(questionSeq: ack.flatMap { Int($0.seq) }, for: clientMessageID)
            return true
        } catch {
            turn.cancel(clientMessageID: clientMessageID)
            if case let .response(statusCode, _)? = error as? TanyaAITransportError,
                ChatBackoff.isUnauthorized(statusCode: statusCode)
            {
                expireSession()
            } else {
                onSendFailed?(error)
            }
            return false
        }
    }

    /// Sesi OMNI habis (401) dari jalur mana pun: tutup stream yang terbuka, berhenti menyambung, dan beri tahu
    /// host sekali. Status ini final selama bridge hidup.
    func expireSession() {
        guard connection != .expired else { return }
        connection = .expired
        connectionTask?.cancel()
        onSessionExpired?()
    }

    /// Event `message` digabung ke daftar; `turn_end` milik pertanyaan yang ditunggu membuka kunci kirim.
    func apply(_ event: ChatEvent) {
        switch event {
        case .message(let message):
            messages = messages.merging([message])
        case .turnEnd(let seq):
            turn.end(seq: seq)
        case .ignored:
            break
        }
    }

    /// History yang sudah dikejar; percakapan berbeda dari sebelumnya mengganti daftar, bukan digabung.
    func replaceOrMerge(_ history: [ChatMessage], conversationID: String) {
        guard self.conversationID == nil || self.conversationID == conversationID else {
            messages = history.merging([])
            turn.cancel()
            eventCursor = nil
            self.conversationID = conversationID
            isHistoryLoaded = true
            return
        }
        self.conversationID = conversationID
        messages = messages.merging(history)
        isHistoryLoaded = true
    }
}
