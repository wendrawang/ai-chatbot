import DesignKit
import SwiftUI
import TanyaAIDomain

struct WelcomeSection: View {
    @Environment(\.theme)
    private var theme
    let configuration: WelcomeConfiguration
    let onSelect: (QuickActionData) -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                WelcomeContent(
                    title: configuration.title, subtitle: configuration.subtitle,
                    sectionTitle: configuration.sectionTitle,
                    actions: configuration.actions, onSelect: onSelect,
                    emblem: { emblem }
                )
                .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
                .padding(.vertical, FigmaSize.spacing16.sizeInArtwork)
                .frame(minHeight: geometry.size.height)
            }
        }
        .accessibilityIdentifier("chat.welcome")
    }

    private var emblem: some View {
        // TODO: Replace the dummy gradient and sparkles with the approved welcome emblem from Figma.
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color(theme.colors.accent), Color(theme.colors.warning)],
                    startPoint: .topTrailing, endPoint: .bottomLeading
                )
            )
            .overlay(
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: DesignKitMetrics.Size.itemIcon.sizeInArtwork,
                        height: DesignKitMetrics.Size.itemIcon.sizeInArtwork
                    )
                    .foregroundColor(Color(theme.colors.userBubbleText))
            )
            .frame(
                width: DesignKitMetrics.Size.emblem.sizeInArtwork,
                height: DesignKitMetrics.Size.emblem.sizeInArtwork
            )
            .background(
                Circle()
                    .fill(Color(theme.colors.accent).opacity(ChatLayoutMetrics.emblemGlowOpacity))
                    .scaleEffect(ChatLayoutMetrics.emblemGlowScale)
            )
            .accessibilityHidden(true)
    }
}
