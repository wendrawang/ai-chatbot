//
//  TanyaAIUseCase.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation

/// Use case Tanya AI di host: memiliki service chat (init, history, SSE, kirim).
/// Sandbox memakai fixture lokal; `--offline` membuat service gagal dan melapor ke halaman host.
final class TanyaAIUseCase {
    let callback: BaseCallback
    let service: SandboxChatService

    init(options: SandboxOptions = .current) {
        let callback = BaseCallback()
        self.callback = callback
        // Error jaringan dilaporkan ke blocker host, selain ke status koneksi di dalam chat.
        service = SandboxChatService(options: options) { error in
            Task { @MainActor in callback.onSubmissionFailed(error) }
        }
    }
}
