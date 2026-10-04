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
            spacing: DesignKitMetrics.Spacing.compact.sizeInArtwork
        ) {
            Text(payload.title)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.primaryText))
                .fixedSize(horizontal: false, vertical: true)
            detail
            buttons
        }
        .padding(DesignKitMetrics.Spacing.wide.sizeInArtwork)
        .background(OutlinedBackground())
        .frame(
            maxWidth: DesignKitMetrics.Size.bubbleMaximumWidth.sizeInArtwork,
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
                .padding(.top, DesignKitMetrics.Spacing.tight.sizeInArtwork)
        } else {
            HStack(spacing: DesignKitMetrics.Spacing.compact.sizeInArtwork) {
                cancelButton
                continueButton
            }
            .padding(.top, DesignKitMetrics.Spacing.tight.sizeInArtwork)
        }
    }

    private var cancelButton: some View {
        Button(action: onCancel) {
            label(payload.cancelTitle ?? copy.chat("chat.cancel"))
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .background(Color(theme.colors.background))
        .cornerRadius(DesignKitMetrics.Radius.bubble.sizeInArtwork)
        .overlay(
            RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.bubble.sizeInArtwork)
                .stroke(
                    Color(theme.colors.divider),
                    lineWidth: DesignKitMetrics.Stroke.hairline.strokeInArtwork
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
        .cornerRadius(DesignKitMetrics.Radius.bubble.sizeInArtwork)
        .accessibilityIdentifier("liveAgent.continue")
    }

    private func label(_ title: String) -> some View {
        Text(title)
            .designFont(.button)
            .frame(
                maxWidth: .infinity,
                minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
            )
    }
}
