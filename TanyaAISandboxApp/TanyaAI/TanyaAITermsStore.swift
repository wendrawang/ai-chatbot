//
//  TanyaAITermsStore.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 26/10/26.
//

import Foundation

/// Persetujuan T&C Tanya AI di perangkat. Versi yang disetujui disimpan agar host bisa
/// menampilkan T&C lagi bila nanti BE memakai versi baru.
struct TanyaAITermsStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var acceptedVersion: String? { defaults.string(forKey: SandboxOptions.termsAcceptedKey) }

    var isAccepted: Bool { acceptedVersion != nil }

    func accept(version: String) {
        defaults.set(version, forKey: SandboxOptions.termsAcceptedKey)
    }

    func reset() {
        defaults.removeObject(forKey: SandboxOptions.termsAcceptedKey)
    }
}
