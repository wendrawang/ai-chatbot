import SwiftUI

public struct QuickActionList: View {
    @Environment(\.theme)
    private var theme
    private let title: String
    private let symbolName: String?
    private let actions: [QuickActionData]
    private let onSelect: (QuickActionData) -> Void

    public init(
        title: String, symbolName: String? = "lightbulb", actions: [QuickActionData],
        onSelect: @escaping (QuickActionData) -> Void
    ) {
        self.title = title
        self.symbolName = symbolName
        self.actions = actions
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing8.sizeInArtwork) {
            HStack(spacing: FigmaSize.spacing8.sizeInArtwork) {
                if let symbolName = symbolName {
                    Image(systemName: symbolName)
                        .foregroundColor(Color(theme.colors.accent))
                        .accessibilityHidden(true)
                }
                Text(title).foregroundColor(Color(theme.colors.primaryText))
            }
            .designFont(.button)
            .padding(.bottom, FigmaSize.spacing8.sizeInArtwork)
            ForEach(actions.indices, id: \.self) { index in
                QuickActionRow(action: actions[index], onSelect: onSelect)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("quick.actions")
    }
}
