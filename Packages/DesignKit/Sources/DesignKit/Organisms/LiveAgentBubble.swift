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
            spacing: DesignKitMetrics.Spacing.compact
        ) {
            Text(payload.title)
                .font(Font(theme.fonts.headline))
                .foregroundColor(Color(theme.colors.primaryText))
                .fixedSize(horizontal: false, vertical: true)
            detail
            buttons
        }
        .padding(DesignKitMetrics.Spacing.wide)
        .background(OutlinedBackground())
        .frame(
            maxWidth: DesignKitMetrics.Size.bubbleMaximumWidth,
            alignment: .leading
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("liveAgent.card")
    }

    @ViewBuilder
    private var detail: some View {
        if let detail = payload.detail, detail.isEmpty == false {
            Text(detail)
                .font(Font(theme.fonts.subheadline))
                .foregroundColor(Color(theme.colors.secondaryText))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var buttons: some View {
        if payload.isDeclined {
            Text(payload.cancelTitle)
                .font(Font(theme.fonts.footnote))
                .foregroundColor(Color(theme.colors.secondaryText))
                .padding(.top, DesignKitMetrics.Spacing.tight)
        } else {
            HStack(spacing: DesignKitMetrics.Spacing.compact) {
                cancelButton
                continueButton
            }
            .padding(.top, DesignKitMetrics.Spacing.tight)
        }
    }

    private var cancelButton: some View {
        Button(action: onCancel) {
            label(payload.cancelTitle)
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .background(Color(theme.colors.background))
        .cornerRadius(DesignKitMetrics.Radius.bubble)
        .overlay(
            RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.bubble)
                .stroke(
                    Color(theme.colors.divider),
                    lineWidth: DesignKitMetrics.Stroke.hairline
                )
        )
        .accessibilityIdentifier("liveAgent.cancel")
    }

    private var continueButton: some View {
        Button(
            action: { onContinue(payload.action) },
            label: { label(payload.continueTitle) }
        )
        .foregroundColor(Color(theme.colors.userBubbleText))
        .background(Color(theme.colors.accent))
        .cornerRadius(DesignKitMetrics.Radius.bubble)
        .accessibilityIdentifier("liveAgent.continue")
    }

    private func label(_ title: String) -> some View {
        Text(title)
            .font(Font(theme.fonts.button))
            .frame(
                maxWidth: .infinity,
                minHeight: DesignKitMetrics.Size.minimumTapTarget
            )
    }
}
