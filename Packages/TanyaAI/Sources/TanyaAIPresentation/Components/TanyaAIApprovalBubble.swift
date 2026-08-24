import SwiftUI
import TanyaAIDomain

struct TanyaAIApprovalBubble: View {
    let payload: TanyaAIApprovalPayload
    let onEdit: () -> Void
    let onCancel: () -> Void
    let onApprove: () -> Void
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            cardDivider
            summary
            notice
            status
            actions
        }
        .background(theme.colors.surface)
        .cornerRadius(18)
        .frame(maxWidth: 340, alignment: .leading)
        .accessibilityElement(children: .contain)
        .tanyaAIAccessibilityIdentifier(
            "confirmation.\(payload.kind.rawValue)"
        )
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: symbolName)
                .font(theme.fonts.headline)
                .foregroundColor(theme.colors.accent)
                .frame(width: 24)
            Text(payload.title)
                .font(theme.fonts.headline)
                .foregroundColor(theme.colors.primaryText)
        }
        .padding(16)
    }

    private var summary: some View {
        VStack(spacing: 12) {
            ForEach(payload.summary.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(payload.summary[index].label)
                        .foregroundColor(theme.colors.secondaryText)
                    Spacer(minLength: 8)
                    Text(payload.summary[index].value)
                        .font(theme.fonts.headline)
                        .multilineTextAlignment(.trailing)
                }
                .font(theme.fonts.subheadline)
            }
        }
        .padding(16)
    }

    @ViewBuilder
    private var notice: some View {
        if let notice = payload.notice {
            Text(notice)
                .font(theme.fonts.footnote)
                .foregroundColor(theme.colors.secondaryText)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
        }
    }

    @ViewBuilder
    private var status: some View {
        if payload.state != .awaitingApproval {
            Text(statusText)
                .font(theme.fonts.footnote)
                .foregroundColor(statusColor)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
        }
    }

    @ViewBuilder
    private var actions: some View {
        if payload.state == .awaitingApproval {
            HStack(spacing: 8) {
                actionButton("Edit", action: onEdit)
                actionButton("Cancel", action: onCancel)
                Button(action: onApprove) {
                    Text(payload.handoff == nil ? "Confirm" : "Continue")
                        .font(theme.fonts.button)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .foregroundColor(theme.colors.userBubbleText)
                .background(theme.colors.accent)
                .cornerRadius(12)
                .tanyaAIAccessibilityIdentifier(
                    "approval.open.\(payload.kind.rawValue)"
                )
            }
            .padding(12)
        }
    }

    private func actionButton(
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(theme.fonts.button)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .foregroundColor(theme.colors.primaryText)
        .background(theme.colors.background)
        .cornerRadius(12)
    }

    private var cardDivider: some View {
        Rectangle()
            .fill(theme.colors.divider)
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
        case .completed: return theme.colors.success
        case .failed, .expired: return theme.colors.error
        default: return theme.colors.secondaryText
        }
    }
}
