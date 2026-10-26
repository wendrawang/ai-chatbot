//
//  MessageList.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
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
    let messages: [ChatMessage]
    let isReplying: Bool
    let handlers: MessageHandlers
    let topInset: CGFloat

    func makeUIViewController(context: Context) -> MessageListController {
        let controller = MessageListController()
        // Scroll programatik terjadi di dalam update SwiftUI; perubahan state ditunda ke siklus berikutnya.
        controller.onScrolledChange = { value in DispatchQueue.main.async { isScrolled = value } }
        return controller
    }

    func updateUIViewController(_ controller: MessageListController, context: Context) {
        controller.handlers = handlers
        controller.tableView.contentInset.top = topInset
        controller.tableView.verticalScrollIndicatorInsets.top = topInset
        controller.show(messages, isReplying: isReplying, locale: locale, colors: colors)
    }
}
