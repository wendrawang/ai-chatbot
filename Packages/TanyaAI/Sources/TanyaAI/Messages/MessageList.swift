//
//  MessageList.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import DesignKit
import SwiftUI

/// Jembatan SwiftUI ke `MessageListController`.
@MainActor
struct MessageList: UIViewControllerRepresentable {
    @Environment(\.locale)
    private var locale
    @Environment(\.designColors)
    private var colors
    @Binding
    var isScrolled: Bool
    @Binding
    var isAtBottom: Bool
    let messages: [ChatMessage]
    let handlers: MessageHandlers
    /// Berganti setiap kali pengguna menekan panah ke pesan terbaru.
    let scrollRequest: UUID
    let topInset: CGFloat

    func makeCoordinator() -> Coordinator { Coordinator(scrollRequest: scrollRequest) }

    func makeUIViewController(context: Context) -> MessageListController {
        let controller = MessageListController()
        controller.onScrollStateChange = { isScrolled, isAtBottom in
            self.isScrolled = isScrolled
            self.isAtBottom = isAtBottom
        }
        return controller
    }

    func updateUIViewController(_ controller: MessageListController, context: Context) {
        controller.handlers = handlers
        controller.tableView.contentInset.top = topInset
        controller.tableView.verticalScrollIndicatorInsets.top = topInset
        controller.show(messages, locale: locale, colors: colors)
        if context.coordinator.scrollRequest != scrollRequest {
            context.coordinator.scrollRequest = scrollRequest
            controller.scrollToLatest()
        }
    }

    final class Coordinator {
        var scrollRequest: UUID

        init(scrollRequest: UUID) {
            self.scrollRequest = scrollRequest
        }
    }
}
