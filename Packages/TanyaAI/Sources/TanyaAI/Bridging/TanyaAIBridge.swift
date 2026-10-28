//
//  TanyaAIBridge.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import Combine

/// Jembatan host ↔ TanyaAI yang hidup selama halaman terbuka. Host membuatnya sekali (misalnya di view model
/// milik `@StateObject` destination) lalu memberikannya ke `TanyaAIHost`. Status menunggu jawaban milik TanyaAI.
/// TODO: Tambah `receive(_:)` untuk event SSE mentah dari host dan event penghenti loading setelah contract ada.
@MainActor
public final class TanyaAIBridge: ObservableObject {
    /// Sejak chat diterima host sampai jawaban selesai; tombol kirim menjadi titik bergerak dan shortcut nonaktif.
    @Published
    private(set) var isAwaitingReply = false
    private let onSend: (String) -> Bool
    private let onNewConversation: (() -> Void)?

    /// `onSend` mengembalikan true bila host menerima chat; false mempertahankan draft di composer.
    /// Tanpa `onNewConversation`, item menu "Percakapan baru" nonaktif.
    public init(onNewConversation: (() -> Void)? = nil, onSend: @escaping (String) -> Bool) {
        self.onSend = onSend
        self.onNewConversation = onNewConversation
    }

    var isNewConversationAvailable: Bool { onNewConversation != nil }

    /// Satu pertanyaan per waktu: selama menunggu jawaban, chat baru ditolak tanpa diteruskan ke host.
    func send(_ text: String) -> Bool {
        guard !isAwaitingReply, onSend(text) else { return false }
        isAwaitingReply = true
        return true
    }

    /// Percakapan baru mengakhiri penantian lokal; sesi BE (init ulang, stream) milik host.
    func startNewConversation() {
        isAwaitingReply = false
        onNewConversation?()
    }
}
