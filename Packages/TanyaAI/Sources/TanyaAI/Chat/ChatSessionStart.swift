//
//  ChatSessionStart.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

/// Hasil init → history → config untuk satu koneksi.
struct ChatSessionStart {
    let sessionId: String
    let page: HistoryPayload
    let welcome: ChatWelcome?
}

extension ChatSessionStart {
    /// Berjalan tanpa memegang view model, jadi halaman yang ditutup bisa langsung dilepas walau
    /// request masih berjalan. Config hanya untuk percakapan kosong; gagal memuatnya tidak menghalangi chat.
    static func load(from service: TanyaAIService, isWelcomeNeeded: Bool) async throws -> ChatSessionStart {
        let session = try ChatPayload.decode(SessionPayload.self, from: await service.start())
        let page = try ChatPayload.decode(
            HistoryPayload.self, from: await service.history(sessionId: session.sessionId, before: nil))
        var welcome: ChatWelcome?
        if isWelcomeNeeded, page.messages.isEmpty,
            let data = try? await service.config(sessionId: session.sessionId),
            let payload = try? ChatPayload.decode(ConfigPayload.self, from: data)
        {
            welcome = ChatWelcome(payload)
        }
        return ChatSessionStart(sessionId: session.sessionId, page: page, welcome: welcome)
    }
}
