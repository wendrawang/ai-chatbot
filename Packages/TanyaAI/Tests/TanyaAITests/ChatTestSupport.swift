//
//  ChatTestSupport.swift
//  TanyaAI
//
//  Created by Wendra on 26/10/26.
//

import Foundation
import Testing

@testable import TanyaAI

/// Percakapan yang sudah siap: sesi terbuka dan stream tersambung.
@MainActor
func openedConversation(_ service: FakeChatService = FakeChatService()) async -> ChatViewModel {
    let viewModel = ChatViewModel(service: service)
    viewModel.start()
    await waitUntil { viewModel.phase == .ready }
    await waitUntil { await service.openedStreams == 1 }
    return viewModel
}

/// Kirim `text`, lalu BE memantulkan pesan user `questionId` lewat stream.
@MainActor
func ask(_ text: String, as questionId: String, in viewModel: ChatViewModel, service: FakeChatService) async {
    _ = viewModel.send(text)
    await waitUntil { await service.sentTexts.last == text }
    await service.emit("message", FakeChatService.message(id: questionId, role: "user", text: text))
    await waitUntil { viewModel.turn == .waiting(questionId: questionId) }
}
