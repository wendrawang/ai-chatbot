//
//  SuggestionList.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import SwiftUI

/// Prompt saran yang bisa digeser horizontal.
@MainActor
public struct SuggestionList: View {
    private let titles: [String]
    private let isEnabled: Bool
    private let onSelect: (Int) -> Void

    /// `onSelect` menerima indeks judul yang diketuk.
    public init(titles: [String], isEnabled: Bool = true, onSelect: @escaping (Int) -> Void) {
        self.titles = titles
        self.isEnabled = isEnabled
        self.onSelect = onSelect
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: FigmaSize.spacingMedium.scaledToArtwork) {
                ForEach(titles.indices, id: \.self) { index in
                    ActionButton(titles[index], style: .suggestion, isEnabled: isEnabled) { onSelect(index) }
                }
            }
            .padding(.vertical, FigmaSize.weightOutline.scaledToArtwork)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(ComponentIdentifier.Action.suggestions)
    }
}
