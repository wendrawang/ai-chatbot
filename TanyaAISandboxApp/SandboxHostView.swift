//
//  SandboxHostView.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI
import TanyaAI

@MainActor
struct SandboxHostView: View {
    @Environment(\.locale)
    private var locale
    @StateObject
    private var host: TanyaAIHost

    init(options: SandboxOptions) {
        _host = StateObject(wrappedValue: TanyaAIHost { _ in !options.isRejectingSend })
    }

    var body: some View {
        NavigationView {
            Button(action: host.present) {
                Text(SandboxCopy.open.text(locale: locale))
            }
            .accessibilityIdentifier(SandboxOptions.openIdentifier)
        }
        .navigationViewStyle(.stack)
        .tanyaAIHost(host)
    }
}
