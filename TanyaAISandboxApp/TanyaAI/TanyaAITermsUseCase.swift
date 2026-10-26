//
//  TanyaAITermsUseCase.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 26/10/26.
//

import Foundation

/// Use case T&C Tanya AI di host: inquiry dan simpan persetujuan ke BE, lalu simpan di perangkat.
struct TanyaAITermsUseCase {
    let service: SandboxTermsService
    let store: TanyaAITermsStore

    init(
        options: SandboxOptions = .current, store: TanyaAITermsStore = TanyaAITermsStore(),
        onFailure: @escaping @Sendable (Error) -> Void = { _ in }
    ) {
        service = SandboxTermsService(options: options, onFailure: onFailure)
        self.store = store
    }

    func inquiry() async throws -> SandboxTerms {
        try await service.inquiry()
    }

    /// Simpan ke BE dulu; perangkat hanya mencatat setelah BE menerima.
    func accept(_ terms: SandboxTerms) async throws {
        try await service.accept(version: terms.version)
        store.accept()
    }
}
