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
    private let isHeaderDemo: Bool

    init(options: SandboxOptions) {
        isHeaderDemo = options.isHeaderDemo
        _host = StateObject(wrappedValue: TanyaAIHost { _ in !options.isRejectingSend })
    }

    var body: some View {
        NavigationView {
            Button(action: open) {
                Text(SandboxCopy.open.text(locale: locale))
            }
            .accessibilityIdentifier(SandboxOptions.openIdentifier)
        }
        .navigationViewStyle(.stack)
        .tanyaAIHost(host)
    }

    private func open() {
        if isHeaderDemo {
            host.present { HeaderDemoContent() }
        } else {
            host.present()
        }
    }
}
