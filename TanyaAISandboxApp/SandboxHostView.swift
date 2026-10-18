//
//  SandboxHostView.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import SwiftUI

/// Main legacy host: NavigationView lamanya tetap di sini; Tanya AI dibuka lewat router host.
@MainActor
struct SandboxHostView: View {
    @Environment(\.locale)
    private var locale
    private let onOpen: () -> Void

    init(onOpen: @escaping () -> Void) {
        self.onOpen = onOpen
    }

    var body: some View {
        NavigationView {
            Button(action: onOpen) {
                Text(String(resource: R.string.localizable.sandboxOpen, locale: locale))
            }
            .accessibilityIdentifier(SandboxOptions.openIdentifier)
        }
        .navigationViewStyle(.stack)
    }
}
