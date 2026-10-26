//
//  TanyaAITermsStore.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 26/10/26.
//

import Foundation

/// Persetujuan T&C Tanya AI di perangkat; sekali disetujui, T&C tidak tampil lagi.
struct TanyaAITermsStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isAccepted: Bool { defaults.bool(forKey: SandboxOptions.termsAcceptedKey) }

    func accept() {
        defaults.set(true, forKey: SandboxOptions.termsAcceptedKey)
    }

    func reset() {
        defaults.removeObject(forKey: SandboxOptions.termsAcceptedKey)
    }
}
