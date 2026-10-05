import DesignKit
import TanyaAIDomain
import SwiftUI

public struct ApprovalBubble: View {
    let payload: ApprovalPayload
    let onEdit: () -> Void
    let onCancel: () -> Void
    let onApprove: () -> Void
    @Environment(\.copyCatalog) private var copy
    @Environment(\.theme) private var theme

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
        .cornerRadius(DesignKitMetrics.Radius.card.sizeInArtwork)
        .frame(maxWidth: DesignKitMetrics.Size.cardMaximumWidth.sizeInArtwork, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(
            "confirmation.\(payload.kind.rawValue)"
        )
    }

    private var header: some View {
        HStack(spacing: DesignKitMetrics.Spacing.medium.sizeInArtwork) {
            Image(systemName: symbolName)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.accent))
                .frame(width: DesignKitMetrics.Size.icon.sizeInArtwork)
            Text(payload.title)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.primaryText))
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .padding(FigmaSize.spacing16.sizeInArtwork)
    }

    private var summary: some View {
        VStack(spacing: DesignKitMetrics.Spacing.regular.sizeInArtwork) {
            ForEach(payload.summary.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline, spacing: DesignKitMetrics.Spacing.regular.sizeInArtwork) {
                    Text(payload.summary[index].label)
                        .foregroundColor(Color(theme.colors.secondaryText))
                    Spacer(minLength: FigmaSize.spacing8.sizeInArtwork)
                    Text(payload.summary[index].value)
                        .designFont(.headline)
                        .multilineTextAlignment(.trailing)
                }
                .designFont(.subheadline)
            }
        }
        .padding(FigmaSize.spacing16.sizeInArtwork)
    }

    @ViewBuilder
    private var notice: some View {
        if let notice = payload.notice {
            Text(notice)
                .designFont(.footnote)
                .foregroundColor(Color(theme.colors.secondaryText))
                .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
                .padding(.bottom, DesignKitMetrics.Spacing.regular.sizeInArtwork)
        }
    }

    @ViewBuilder
    private var status: some View {
        if payload.state != .awaitingApproval {
            Text(statusText)
                .designFont(.footnote)
                .foregroundColor(statusColor)
                .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
                .padding(.bottom, DesignKitMetrics.Spacing.regular.sizeInArtwork)
        }
    }

    @ViewBuilder
    private var actions: some View {
        if payload.state == .awaitingApproval {
            HStack(spacing: FigmaSize.spacing8.sizeInArtwork) {
                actionButton(copy.chat("chat.edit"), action: onEdit)
                actionButton(copy.chat("chat.cancel"), action: onCancel)
                Button(action: onApprove) {
                    Text(copy.chat("chat.confirm"))
                        .designFont(.button)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
                        )
                }
                .buttonStyle(DesignButtonStyle())
                .accessibilityIdentifier(
                    "approval.open.\(payload.kind.rawValue)"
                )
            }
            .padding(DesignKitMetrics.Spacing.regular.sizeInArtwork)
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
                    minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
                )
        }
        .buttonStyle(DesignButtonStyle(.secondary))
    }

    private var cardDivider: some View {
        Rectangle()
            .fill(Color(theme.colors.divider))
            .frame(height: DesignKitMetrics.Stroke.divider.strokeInArtwork)
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
        case .awaitingApproval: return copy.chat("chat.awaitingApproval")
        case .authorizing: return copy.chat("chat.authorizing")
        case .processing: return copy.chat("chat.processing")
        case .completed: return copy.chat("chat.completed")
        case .failed: return copy.chat("chat.authorizationFailed")
        case .expired: return copy.chat("chat.approvalExpired")
        case .cancelled: return copy.chat("chat.cancelled")
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
