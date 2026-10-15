//
//  HostedChatScreen.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import SwiftUI

/// The feature owns its close control; the host's NavigationView stays underneath the presentation.
@MainActor
struct HostedChatScreen: View {
    @Environment(\.locale)
    private var locale
    let isEnabled: Bool
    let onSend: (String) -> Bool
    let onClose: () -> Void

    var body: some View {
        NavigationView {
            ChatScreen(isEnabled: isEnabled, onSend: onSend)
                .navigationTitle(ChatCopy.title.text(locale: locale))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: onClose) { SystemSymbol.back.image }
                            .accessibilityLabel(ChatCopy.back.text(locale: locale))
                    }
                }
        }
        .navigationViewStyle(.stack)
        .accentColor(DefaultColorConstants().colorsButtonActive)
    }
}
