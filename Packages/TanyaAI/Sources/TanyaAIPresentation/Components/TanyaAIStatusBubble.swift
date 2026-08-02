import SwiftUI
import TanyaAIDomain

struct TanyaAIStatusBubble: View {
    let payload: TanyaAIStatusPayload
    @Environment(\.tanyaAITheme) private var theme

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: iconName)
                .foregroundColor(accentColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(payload.title)
                    .font(Font(theme.fonts.headline))
                Text(payload.detail)
                    .font(Font(theme.fonts.subheadline))
                    .foregroundColor(Color(theme.colors.secondaryText))
            }
        }
        .padding(16)
        .background(Color(theme.colors.surface))
        .cornerRadius(16)
        .frame(maxWidth: 340, alignment: .leading)
    }

    private var iconName: String {
        switch payload.level {
        case .neutral: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.octagon.fill"
        }
    }

    private var accentColor: Color {
        switch payload.level {
        case .neutral: return Color(theme.colors.accent)
        case .success: return Color(theme.colors.success)
        case .warning: return Color(theme.colors.warning)
        case .error: return Color(theme.colors.error)
        }
    }
}
