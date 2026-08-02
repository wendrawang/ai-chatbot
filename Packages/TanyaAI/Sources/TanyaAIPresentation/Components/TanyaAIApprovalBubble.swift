import SwiftUI
import TanyaAIDomain

struct TanyaAIApprovalBubble: View {
    let payload: TanyaAIApprovalPayload
    let onApprove: () -> Void
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(payload.title)
                .font(Font(theme.fonts.headline))

            summary
            status

            if payload.state == .awaitingApproval {
                Button(action: onApprove) {
                    Text("Review and approve")
                        .font(Font(theme.fonts.button))
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .foregroundColor(Color(theme.colors.userBubbleText))
                .background(Color(theme.colors.accent))
                .cornerRadius(10)
                .tanyaAIAccessibilityIdentifier("approval.open")
            }
        }
        .padding(16)
        .background(Color(theme.colors.surface))
        .cornerRadius(16)
        .frame(maxWidth: 340, alignment: .leading)
    }

    private var summary: some View {
        VStack(spacing: 8) {
            ForEach(payload.summary.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline) {
                    Text(payload.summary[index].label)
                        .foregroundColor(Color(theme.colors.secondaryText))
                    Spacer(minLength: 12)
                    Text(payload.summary[index].value)
                        .font(Font(theme.fonts.headline))
                }
                .font(Font(theme.fonts.subheadline))
            }
        }
    }

    private var status: some View {
        Text(statusText)
            .font(Font(theme.fonts.footnote))
            .foregroundColor(statusColor)
    }

    private var statusText: String {
        switch payload.state {
        case .awaitingApproval: return "Awaiting your approval"
        case .authorizing: return "Authorizing securely"
        case .processing: return "Processing"
        case .completed: return "Completed"
        case .failed: return "Authorization failed"
        case .expired: return "Approval expired"
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
