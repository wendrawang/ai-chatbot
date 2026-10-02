import DesignKit
import TanyaAIDomain
import SwiftUI

public struct ApprovalBubble: View {
    let payload: ApprovalPayload
    let onEdit: () -> Void
    let onCancel: () -> Void
    let onApprove: () -> Void
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    public init(
        payload: ApprovalPayload,
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
        .cornerRadius(artwork.size(DesignKitMetrics.Radius.card))
        .frame(maxWidth: artwork.size(DesignKitMetrics.Size.cardMaximumWidth), alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(
            "confirmation.\(payload.kind.rawValue)"
        )
    }

    private var header: some View {
        HStack(spacing: artwork.size(DesignKitMetrics.Spacing.medium)) {
            Image(systemName: symbolName)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.accent))
                .frame(width: artwork.size(DesignKitMetrics.Size.icon))
            Text(payload.title)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.primaryText))
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .padding(artwork.size(DesignKitMetrics.Spacing.wide))
    }

    private var summary: some View {
        VStack(spacing: artwork.size(DesignKitMetrics.Spacing.regular)) {
            ForEach(payload.summary.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline, spacing: artwork.size(DesignKitMetrics.Spacing.regular)) {
                    Text(payload.summary[index].label)
                        .foregroundColor(Color(theme.colors.secondaryText))
                    Spacer(minLength: artwork.size(DesignKitMetrics.Spacing.compact))
                    Text(payload.summary[index].value)
                        .designFont(.headline)
                        .multilineTextAlignment(.trailing)
                }
                .designFont(.subheadline)
            }
        }
        .padding(artwork.size(DesignKitMetrics.Spacing.wide))
    }

    @ViewBuilder
    private var notice: some View {
        if let notice = payload.notice {
            Text(notice)
                .designFont(.footnote)
                .foregroundColor(Color(theme.colors.secondaryText))
                .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.wide))
                .padding(.bottom, artwork.size(DesignKitMetrics.Spacing.regular))
        }
    }

    @ViewBuilder
    private var status: some View {
        if payload.state != .awaitingApproval {
            Text(statusText)
                .designFont(.footnote)
                .foregroundColor(statusColor)
                .padding(.horizontal, artwork.size(DesignKitMetrics.Spacing.wide))
                .padding(.bottom, artwork.size(DesignKitMetrics.Spacing.regular))
        }
    }

    @ViewBuilder
    private var actions: some View {
        if payload.state == .awaitingApproval {
            HStack(spacing: artwork.size(DesignKitMetrics.Spacing.compact)) {
                actionButton(ChatCopy.text("Edit"), action: onEdit)
                actionButton(ChatCopy.text("Cancel"), action: onCancel)
                Button(action: onApprove) {
                    Text(ChatCopy.text("Confirm"))
                        .designFont(.button)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: artwork.tapTarget()
                        )
                }
                .buttonStyle(DesignButtonStyle())
                .accessibilityIdentifier(
                    "approval.open.\(payload.kind.rawValue)"
                )
            }
            .padding(artwork.size(DesignKitMetrics.Spacing.regular))
        }
    }

    private func actionButton(
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .designFont(.button)
                .frame(
                    maxWidth: .infinity,
                    minHeight: artwork.tapTarget(DesignKitMetrics.Size.minimumTapTarget)
                )
        }
        .buttonStyle(DesignButtonStyle(.secondary))
    }

    private var cardDivider: some View {
        Rectangle()
            .fill(Color(theme.colors.divider))
            .frame(height: artwork.stroke(0.5))
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
        case .awaitingApproval: return ChatCopy.text("Awaiting your approval")
        case .authorizing: return ChatCopy.text("Authorizing securely")
        case .processing: return ChatCopy.text("Processing")
        case .completed: return ChatCopy.text("Completed")
        case .failed: return ChatCopy.text("Authorization failed")
        case .expired: return ChatCopy.text("Approval expired")
        case .cancelled: return ChatCopy.text("Cancelled")
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
