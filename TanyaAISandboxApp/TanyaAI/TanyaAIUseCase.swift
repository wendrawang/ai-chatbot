//
//  TanyaAIUseCase.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation

/// Use case Tanya AI di host: memiliki service chat (init, history, config, SSE, kirim, cancel).
/// Sandbox memakai fixture lokal; `--offline` membuat service gagal dan `onFailure` dipanggil.
struct TanyaAIUseCase {
    let service: SandboxChatService

    init(options: SandboxOptions = .current, onFailure: @escaping @Sendable (Error) -> Void = { _ in }) {
        service = SandboxChatService(options: options, onFailure: onFailure)
    }
}
