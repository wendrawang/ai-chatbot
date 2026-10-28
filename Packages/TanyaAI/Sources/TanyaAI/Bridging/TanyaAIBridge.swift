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
    /// Sejak kirim sampai event `turn_end`; tombol kirim menjadi titik bergerak dan shortcut nonaktif.
    @Published
    private(set) var isAwaitingReply = false
    /// True setelah history pertama selesai; sebelum itu halaman menampilkan loading, bukan sambutan.
    @Published
    private(set) var isHistoryLoaded = false
    @Published
    var connection = ChatConnection.connecting
    /// Percakapan dari `/chat/init` terakhir; nil sebelum init pertama berhasil.
    var conversationID: String?
    let transport: TanyaAIChatTransport
    let onSessionExpired: (() -> Void)?
    let sleep: (TimeInterval) async throws -> Void
    private let onNewConversation: (() -> Void)?

    /// `onSessionExpired` dipanggil sekali saat gateway menjawab 401 (sesi OMNI habis); stream tidak dibuka lagi.
    /// Tanpa `onNewConversation`, item menu "Percakapan baru" nonaktif.
    public convenience init(
        transport: TanyaAIChatTransport, onSessionExpired: (() -> Void)? = nil,
        onNewConversation: (() -> Void)? = nil
    ) {
        self.init(
            transport: transport, onSessionExpired: onSessionExpired, onNewConversation: onNewConversation,
            sleep: ChatBackoff.sleep(seconds:)
        )
    }

    /// `sleep` disuntikkan test agar jeda reconnect instan.
    init(
        transport: TanyaAIChatTransport, onSessionExpired: (() -> Void)?, onNewConversation: (() -> Void)?,
        sleep: @escaping (TimeInterval) async throws -> Void
    ) {
        self.transport = transport
        self.onSessionExpired = onSessionExpired
        self.onNewConversation = onNewConversation
        self.sleep = sleep
    }

    var isNewConversationAvailable: Bool { onNewConversation != nil }

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
        isAwaitingReply = true
        do {
            _ = try await transport.sendMessage(
                conversationID: conversationID, clientMessageID: UUID().uuidString, text: text
            )
            return true
        } catch {
            isAwaitingReply = false
            return false
        }
    }

    /// TODO: Sepakati alur percakapan baru dengan BE (`X-New-Conversation` dibatasi 1 percakapan per CIF,
    /// endpoint close belum dipakai). Sementara hanya mengosongkan tampilan lokal (kembali ke sambutan),
    /// mengakhiri penantian, dan memberi tahu host; percakapan di gateway tetap yang lama.
    func startNewConversation() {
        messages = []
        isAwaitingReply = false
        onNewConversation?()
    }

    /// Event `message` digabung ke daftar; `turn_end` membuka kunci kirim.
    func apply(_ event: ChatEvent) {
        switch event {
        case .message(let message):
            messages = messages.merging([message])
        case .turnEnd:
            isAwaitingReply = false
        case .ignored:
            break
        }
    }

    /// History yang sudah dikejar; percakapan berbeda dari sebelumnya mengganti daftar, bukan digabung.
    func replaceOrMerge(_ history: [ChatMessage], conversationID: String) {
        guard self.conversationID == nil || self.conversationID == conversationID else {
            messages = history.merging([])
            isAwaitingReply = false
            self.conversationID = conversationID
            isHistoryLoaded = true
            return
        }
        self.conversationID = conversationID
        messages = messages.merging(history)
        isHistoryLoaded = true
    }
}
