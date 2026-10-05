import SwiftUI

public struct StatusBubble: View {
    let payload: StatusPayload
    @Environment(\.theme) private var theme

    public init(payload: StatusPayload) {
        self.payload = payload
    }

    public var body: some View {
        HStack(alignment: .top, spacing: DesignKitMetrics.Spacing.medium.sizeInArtwork) {
            Image(systemName: iconName)
                .foregroundColor(accentColor)

            VStack(alignment: .leading, spacing: FigmaSize.spacing4.sizeInArtwork) {
                Text(payload.title)
                    .designFont(.headline)
                Text(payload.detail)
                    .designFont(.subheadline)
                    .foregroundColor(Color(theme.colors.secondaryText))
            }
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .padding(FigmaSize.spacing16.sizeInArtwork)
        .background(Color(theme.colors.surface))
        .cornerRadius(DesignKitMetrics.Radius.notice.sizeInArtwork)
        .frame(maxWidth: DesignKitMetrics.Size.cardMaximumWidth.sizeInArtwork, alignment: .leading)
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
