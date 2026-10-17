//
//  ChatHostAnchor.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI
import UIKit

/// Connects to the visible host controller without looking up a global window or changing navigation.
/// Removing the anchor (e.g. main replaced by prelogin) also closes the feature it owns.
@MainActor
struct ChatHostAnchor: UIViewControllerRepresentable {
    let host: TanyaAIHost

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.isUserInteractionEnabled = false
        controller.view.backgroundColor = .clear
        return controller
    }

    func updateUIViewController(_ controller: UIViewController, context: Context) {
        // Update biasa tidak boleh melepas anchor, karena melepas anchor menutup fitur.
        if context.coordinator.host !== host {
            context.coordinator.host?.detach(anchor: controller)
            context.coordinator.host = host
        }
        host.attach(anchor: controller)
    }

    static func dismantleUIViewController(_ controller: UIViewController, coordinator: Coordinator) {
        coordinator.host?.detach(anchor: controller)
        coordinator.host = nil
    }

    final class Coordinator {
        weak var host: TanyaAIHost?
    }
}

public extension View {
    /// Attach once to the visible root owning this host; call `host.present()` from any entry point.
    @MainActor
    func tanyaAIHost(_ host: TanyaAIHost) -> some View {
        tanyaAIHost(Optional(host))
    }

    /// Nil removes the anchor while keeping the main content's identity and state.
    @MainActor
    func tanyaAIHost(_ host: TanyaAIHost?) -> some View {
        background(
            Group {
                if let host {
                    ChatHostAnchor(host: host)
                        .frame(width: .zero, height: .zero)
                }
            }
        )
    }
}
