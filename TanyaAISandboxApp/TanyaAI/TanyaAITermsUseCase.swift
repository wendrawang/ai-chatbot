//
//  TanyaAITermsUseCase.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 26/10/26.
//

import Foundation

/// Use case T&C Tanya AI di host: inquiry dan simpan persetujuan ke BE, lalu simpan di perangkat.
final class TanyaAITermsUseCase {
    let callback: BaseCallback
    let service: SandboxTermsService
    let store: TanyaAITermsStore

    init(options: SandboxOptions = .current, store: TanyaAITermsStore = TanyaAITermsStore()) {
        let callback = BaseCallback()
        self.callback = callback
        self.store = store
        service = SandboxTermsService(options: options) { error in
            Task { @MainActor in callback.onSubmissionFailed(error) }
        }
    }

    func inquiry() async throws -> SandboxTerms {
        try await service.inquiry()
    }

    /// Simpan ke BE dulu; perangkat hanya mencatat setelah BE menerima.
    func accept(_ terms: SandboxTerms) async throws {
        try await service.accept(version: terms.version)
        store.accept(version: terms.version)
    }
}
