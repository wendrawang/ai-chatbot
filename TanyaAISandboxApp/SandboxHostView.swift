//
//  SandboxHostView.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
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
        _host = StateObject(
            wrappedValue: TanyaAIHost(locale: options.locale ?? .current) { _ in !options.isRejectingSend }
        )
    }

    var body: some View {
        NavigationView {
            Button(action: open) {
                Text(String(resource: R.string.localizable.sandboxOpen, locale: locale))
            }
            .accessibilityIdentifier(SandboxOptions.openIdentifier)
        }
        .navigationViewStyle(.stack)
        .tanyaAIHost(host)
    }
}

// MARK: - Actions

private extension SandboxHostView {
    func open() {
        if isHeaderDemo {
            host.present { HeaderDemoContent() }
        } else {
            host.present()
        }
    }
}
