//
//  HostedChatScreen.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI

/// The feature owns its header; the host's NavigationView stays underneath the presentation.
@MainActor
struct HostedChatScreen<Content: View>: View {
    let isEnabled: Bool
    let onSend: (String) -> Bool
    let onClose: () -> Void
    let onNewConversation: (() -> Void)?
    let content: Content

    var body: some View {
        ChatScreen(
            isEnabled: isEnabled, onBack: onClose, onNewConversation: onNewConversation,
            onSend: onSend, content: { content }
        )
    }
}
