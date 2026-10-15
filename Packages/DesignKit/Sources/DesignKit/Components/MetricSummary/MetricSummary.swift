import SwiftUI

public struct MetricSummary: View {
    @Environment(\.theme)
    private var theme
    @State
    private var availableWidth: CGFloat = 0
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
            if isInline {
                HStack(alignment: .firstTextBaseline, spacing: FigmaSize.spacing8.sizeInArtwork) {
                    amount
                    changeLabel
                }
            } else {
                VStack(alignment: .leading, spacing: FigmaSize.spacing8.sizeInArtwork) {
                    amount
                    changeLabel
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(widthReader)
        .onPreferenceChange(MetricWidthPreference.self) { width in
            if width.isFinite, abs(width - availableWidth) > DesignKitMetrics.Layout.measurementTolerance {
                availableWidth = width
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var amount: some View {
        Text(value)
            .designFont(.amount)
            .foregroundColor(Color(theme.colors.primaryText))
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var changeLabel: some View {
        if let change = change {
            Label(change, systemImage: isPositive ? "arrow.up.right" : "arrow.down.right")
                .designFont(.footnote)
                .foregroundColor(Color(isPositive ? theme.colors.success : theme.colors.error))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Keep the Figma inline layout when both values fit; give long values their own row.
    private var isInline: Bool {
        guard let change, availableWidth > 0 else { return false }
        let amountWidth = (value as NSString).size(withAttributes: [.font: theme.fonts.amount]).width
        let changeWidth = (change as NSString).size(withAttributes: [.font: theme.fonts.footnote]).width
        let iconWidth = theme.fonts.footnote.lineHeight
        return amountWidth + changeWidth + iconWidth + FigmaSize.spacing8.sizeInArtwork * 2 <= availableWidth
    }

    private var widthReader: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: MetricWidthPreference.self, value: geometry.size.width)
        }
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

private struct MetricWidthPreference: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
