//
//  SandboxTermsService.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 26/10/26.
//

import Foundation

/// Peran host untuk sandbox: inquiry T&C dan simpan persetujuan ke BE, dari fixture lokal.
/// Simpan ke BE belum pasti dibutuhkan; bila tidak, hapus `accept` dan pemanggilnya di use case.
actor SandboxTermsService {
    private let isOffline: Bool
    private let onFailure: @Sendable (Error) -> Void
    private(set) var acceptedVersions: [String] = []

    init(options: SandboxOptions, onFailure: @escaping @Sendable (Error) -> Void = { _ in }) {
        isOffline = options.isOffline
        self.onFailure = onFailure
    }

    func inquiry() async throws -> SandboxTerms {
        try failIfOffline()
        guard let url = SandboxFixtureFile.termsDummy.url else { throw URLError(.fileDoesNotExist) }
        return try JSONDecoder().decode(SandboxTerms.self, from: Data(contentsOf: url))
    }

    func accept(version: String) async throws {
        try failIfOffline()
        acceptedVersions.append(version)
    }

    private func failIfOffline() throws {
        guard isOffline else { return }
        let error = URLError(.notConnectedToInternet)
        onFailure(error)
        throw error
    }
}
