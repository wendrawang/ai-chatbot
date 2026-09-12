import SwiftUI

public struct TanyaAIApprovalBubble: View {
    let payload: TanyaAIApprovalPayload
    let onEdit: () -> Void
    let onCancel: () -> Void
    let onApprove: () -> Void
    @Environment(\.tanyaAITheme) private var theme

    public init(
        payload: TanyaAIApprovalPayload,
        onEdit: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        onApprove: @escaping () -> Void
    ) {
        self.payload = payload
        self.onEdit = onEdit
        self.onCancel = onCancel
        self.onApprove = onApprove
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            cardDivider
            summary
            notice
            status
            actions
        }
        .background(Color(theme.colors.surface))
        .cornerRadius(DesignKitMetrics.Radius.card)
        .frame(maxWidth: 340, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(
            "confirmation.\(payload.kind.rawValue)"
        )
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: symbolName)
                .font(Font(theme.fonts.headline))
                .foregroundColor(Color(theme.colors.accent))
                .frame(width: 24)
            Text(payload.title)
                .font(Font(theme.fonts.headline))
                .foregroundColor(Color(theme.colors.primaryText))
        }
        .padding(DesignKitMetrics.Spacing.wide)
    }

    private var summary: some View {
        VStack(spacing: DesignKitMetrics.Spacing.regular) {
            ForEach(payload.summary.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline, spacing: DesignKitMetrics.Spacing.regular) {
                    Text(payload.summary[index].label)
                        .foregroundColor(Color(theme.colors.secondaryText))
                    Spacer(minLength: 8)
                    Text(payload.summary[index].value)
                        .font(Font(theme.fonts.headline))
                        .multilineTextAlignment(.trailing)
                }
                .font(Font(theme.fonts.subheadline))
            }
        }
        .padding(DesignKitMetrics.Spacing.wide)
    }

    @ViewBuilder
    private var notice: some View {
        if let notice = payload.notice {
            Text(notice)
                .font(Font(theme.fonts.footnote))
                .foregroundColor(Color(theme.colors.secondaryText))
                .padding(.horizontal, DesignKitMetrics.Spacing.wide)
                .padding(.bottom, 12)
        }
    }

    @ViewBuilder
    private var status: some View {
        if payload.state != .awaitingApproval {
            Text(statusText)
                .font(Font(theme.fonts.footnote))
                .foregroundColor(statusColor)
                .padding(.horizontal, DesignKitMetrics.Spacing.wide)
                .padding(.bottom, 12)
        }
    }

    @ViewBuilder
    private var actions: some View {
        if payload.state == .awaitingApproval {
            HStack(spacing: DesignKitMetrics.Spacing.compact) {
                actionButton("Edit", action: onEdit)
                actionButton("Cancel", action: onCancel)
                Button(action: onApprove) {
                    Text("Confirm")
                        .font(Font(theme.fonts.button))
                        .frame(
                    maxWidth: .infinity,
                    minHeight: DesignKitMetrics.Size.minimumTapTarget
                )
                }
                .foregroundColor(Color(theme.colors.userBubbleText))
                .background(Color(theme.colors.accent))
                .cornerRadius(DesignKitMetrics.Radius.bubble)
                .accessibilityIdentifier(
                    "approval.open.\(payload.kind.rawValue)"
                )
            }
            .padding(DesignKitMetrics.Spacing.regular)
        }
    }

    private func actionButton(
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(Font(theme.fonts.button))
                .frame(
                    maxWidth: .infinity,
                    minHeight: DesignKitMetrics.Size.minimumTapTarget
                )
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .background(Color(theme.colors.background))
        .cornerRadius(DesignKitMetrics.Radius.bubble)
    }

    private var cardDivider: some View {
        Rectangle()
            .fill(Color(theme.colors.divider))
            .frame(height: 0.5)
    }

    private var symbolName: String {
        switch payload.kind {
        case .currencyConversion: return "arrow.left.arrow.right"
        case .timeDeposit: return "lock"
        case .transfer: return "arrow.up.arrow.down"
        case .savingsPlan: return "target"
        case .generic: return "checkmark.shield"
        }
    }

    private var statusText: String {
        switch payload.state {
        case .awaitingApproval: return "Awaiting your approval"
        case .authorizing: return "Authorizing securely"
        case .processing: return "Processing"
        case .completed: return "Completed"
        case .failed: return "Authorization failed"
        case .expired: return "Approval expired"
        case .cancelled: return "Cancelled"
        }
    }

    private var statusColor: Color {
        switch payload.state {
        case .completed: return Color(theme.colors.success)
        case .failed, .expired: return Color(theme.colors.error)
        default: return Color(theme.colors.secondaryText)
        }
    }
}
