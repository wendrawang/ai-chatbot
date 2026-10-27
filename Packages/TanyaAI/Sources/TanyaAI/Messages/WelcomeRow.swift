//
//  WelcomeRow.swift
//  TanyaAI
//
//  Created by Wendra on 26/10/26.
//

import DesignKit
import SwiftUI

/// Greeting dari config dan shortcut di bawahnya, untuk percakapan yang masih kosong.
@MainActor
struct WelcomeRow: View {
    @Environment(\.designColors)
    private var colors
    let welcome: ChatWelcome
    let onShortcut: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacingLarge.scaledToArtwork) {
            Text(welcome.greeting)
                .foregroundColor(colors.colorsTextPrimaryDark)
                .frame(maxWidth: .infinity, alignment: .leading)
            if !welcome.shortcuts.isEmpty {
                shortcuts
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(ChatElementIdentifier.welcome)
    }

    private var shortcuts: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacingMedium.scaledToArtwork) {
            ForEach(welcome.shortcuts) { shortcut in
                SuggestionChip(title: shortcut.label) { onShortcut(shortcut.message) }
            }
        }
    }
}
