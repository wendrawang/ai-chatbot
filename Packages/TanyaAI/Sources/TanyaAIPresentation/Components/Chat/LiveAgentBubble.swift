import DesignKit
import TanyaAIDomain
import SwiftUI

/// Offers to hand the conversation to a person.
///
/// Two buttons rather than the underlined link a `content.actions` hand-off
/// gets. A link is somewhere to go; this is a question with an answer, and the
/// answer includes saying no.
public struct LiveAgentBubble: View {
    let payload: LiveAgentPayload
    let onContinue: (Action) -> Void
    let onCancel: () -> Void
    @Environment(\.copyCatalog) private var copy
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    public init(
        payload: LiveAgentPayload,
        onContinue: @escaping (Action) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.payload = payload
        self.onContinue = onContinue
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: artwork.size(DesignKitMetrics.Spacing.compact)
        ) {
            Text(payload.title)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.primaryText))
                .fixedSize(horizontal: false, vertical: true)
            detail
            buttons
        }
        .padding(artwork.size(DesignKitMetrics.Spacing.wide))
        .background(OutlinedBackground())
        .frame(
            maxWidth: artwork.size(DesignKitMetrics.Size.bubbleMaximumWidth),
            alignment: .leading
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("liveAgent.card")
    }

    @ViewBuilder
    private var detail: some View {
        if let detail = payload.detail, detail.isEmpty == false {
            Text(detail)
                .designFont(.subheadline)
                .foregroundColor(Color(theme.colors.secondaryText))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var buttons: some View {
        if payload.isDeclined {
            Text(payload.cancelTitle ?? copy.chat("chat.cancel"))
                .designFont(.footnote)
                .foregroundColor(Color(theme.colors.secondaryText))
                .padding(.top, artwork.size(DesignKitMetrics.Spacing.tight))
        } else {
            HStack(spacing: artwork.size(DesignKitMetrics.Spacing.compact)) {
                cancelButton
                continueButton
            }
            .padding(.top, artwork.size(DesignKitMetrics.Spacing.tight))
        }
    }

    private var cancelButton: some View {
        Button(action: onCancel) {
            label(payload.cancelTitle ?? copy.chat("chat.cancel"))
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .background(Color(theme.colors.background))
        .cornerRadius(artwork.size(DesignKitMetrics.Radius.bubble))
        .overlay(
            RoundedRectangle(cornerRadius: artwork.size(DesignKitMetrics.Radius.bubble))
                .stroke(
                    Color(theme.colors.divider),
                    lineWidth: artwork.stroke(DesignKitMetrics.Stroke.hairline)
                )
        )
        .accessibilityIdentifier("liveAgent.cancel")
    }

    private var continueButton: some View {
        Button(
            action: { onContinue(payload.action) },
            label: { label(payload.continueTitle ?? copy.chat("chat.continue")) }
        )
        .foregroundColor(Color(theme.colors.userBubbleText))
        .background(Color(theme.colors.accent))
        .cornerRadius(artwork.size(DesignKitMetrics.Radius.bubble))
        .accessibilityIdentifier("liveAgent.continue")
    }

    private func label(_ title: String) -> some View {
        Text(title)
            .designFont(.button)
            .frame(
                maxWidth: .infinity,
                minHeight: artwork.tapTarget(DesignKitMetrics.Size.minimumTapTarget)
            )
    }
}
