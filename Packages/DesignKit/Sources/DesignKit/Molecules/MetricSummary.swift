import SwiftUI

public struct MetricSummary: View {
    @Environment(\.theme)
    private var theme
    private let title: String
    private let value: String
    private let change: String?
    private let isPositive: Bool
    private let infoLabel: String?
    private let onInfo: (() -> Void)?

    public init(
        title: String, value: String, change: String? = nil, isPositive: Bool = true,
        infoLabel: String? = nil, onInfo: (() -> Void)? = nil
    ) {
        self.title = title
        self.value = value
        self.change = change
        self.isPositive = isPositive
        self.infoLabel = infoLabel
        self.onInfo = onInfo
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing4.sizeInArtwork) {
            header
            HStack(alignment: .firstTextBaseline, spacing: FigmaSize.spacing8.sizeInArtwork) {
                Text(value)
                    .designFont(.amount)
                    .foregroundColor(Color(theme.colors.primaryText))
                    .fixedSize(horizontal: false, vertical: true)
                if let change = change {
                    Label(change, systemImage: isPositive ? "arrow.up.right" : "arrow.down.right")
                        .designFont(.footnote)
                        .foregroundColor(Color(isPositive ? theme.colors.success : theme.colors.error))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: FigmaSize.spacing4.sizeInArtwork) {
            Text(title)
                .designFont(.caption)
                .foregroundColor(Color(theme.colors.secondaryText))
                .fixedSize(horizontal: false, vertical: true)
            if let onInfo = onInfo, let infoLabel = infoLabel {
                Button(action: onInfo) {
                    Image(systemName: "info.circle")
                        .designFont(.footnote)
                        .foregroundColor(Color(theme.colors.secondaryText))
                        .frame(
                            minWidth: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                            minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(infoLabel)
            }
        }
    }
}
