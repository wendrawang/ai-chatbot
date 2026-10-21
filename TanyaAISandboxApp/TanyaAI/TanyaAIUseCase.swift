//
//  TanyaAIUseCase.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation
import TanyaAI

/// Use case Tanya AI di host: memiliki service chat (SSE + inquiry BE).
/// Sandbox memakai fixture lokal; `--offline` membuat service gagal dan melapor ke halaman host.
final class TanyaAIUseCase {
    let callback: BaseCallback
    let service: TanyaAIService

    init(options: SandboxOptions = .current) {
        let callback = BaseCallback()
        self.callback = callback
        // Error jaringan dilaporkan ke blocker host, selain ke pesan error di dalam chat.
        service = SandboxChatService(isOffline: options.isOffline) { error in
            Task { @MainActor in callback.onSubmissionFailed(error) }
        }
    }
}
