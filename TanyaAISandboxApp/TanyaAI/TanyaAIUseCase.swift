//
//  TanyaAIUseCase.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation

/// Sandbox: menerima draft tanpa backend. `--reject-send` menolak draft;
/// `--offline` melaporkan error tidak ada internet ke view model.
final class TanyaAIUseCase {
    let callback = BaseCallback()
    private let options: SandboxOptions

    init(options: SandboxOptions = .current) {
        self.options = options
    }

    /// true = draft diterima host; false = draft tetap di composer.
    func send(_ text: String) -> Bool {
        // TODO: Panggil service chat host setelah contract BE tersedia.
        guard !options.isOffline else {
            callback.onSubmissionFailed(URLError(.notConnectedToInternet))
            return false
        }
        return !options.isRejectingSend
    }
}
