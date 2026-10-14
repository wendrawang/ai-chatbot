import SwiftUI

/// A welcome panel with caller-supplied copy, display actions and artwork.
/// The caller owns background, screen placement, margins and navigation.
public struct WelcomeContent<Emblem: View>: View {
    @Environment(\.theme)
    private var theme
    private let title: String
    private let subtitle: String
    private let sectionTitle: String
    private let actions: [QuickActionData]
    private let onSelect: (QuickActionData) -> Void
    private let emblem: Emblem

    public init(
        title: String, subtitle: String, sectionTitle: String, actions: [QuickActionData],
        onSelect: @escaping (QuickActionData) -> Void, @ViewBuilder emblem: () -> Emblem
    ) {
        self.title = title
        self.subtitle = subtitle
        self.sectionTitle = sectionTitle
        self.actions = actions
        self.onSelect = onSelect
        self.emblem = emblem()
    }

    public var body: some View {
        VStack(spacing: FigmaSize.spacing32.sizeInArtwork) {
            greeting
            QuickActionList(title: sectionTitle, actions: actions, onSelect: onSelect)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("welcome.content")
    }

    private var greeting: some View {
        VStack(spacing: FigmaSize.spacing16.sizeInArtwork) {
            emblem
                .frame(
                    width: DesignKitMetrics.Size.emblem.sizeInArtwork,
                    height: DesignKitMetrics.Size.emblem.sizeInArtwork
                )
                .accessibilityHidden(true)
            Text(title)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.primaryText))
            Text(subtitle)
                .designFont(.subheadline)
                .foregroundColor(Color(theme.colors.secondaryText))
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
    }
}
