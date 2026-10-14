import SwiftUI

/// A centered title with balanced control slots. The system status bar and
/// safe area belong to the screen; callbacks live in the supplied controls.
public struct NavigationHeader<Leading: View, Trailing: View>: View {
    @Environment(\.theme)
    private var theme
    private let title: String
    private let leading: Leading
    private let trailing: Trailing

    public init(
        title: String, @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: FigmaSize.spacing8.sizeInArtwork) {
            leading.frame(
                width: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                height: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
            )
            Text(title)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.primaryText))
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)
            trailing.frame(
                width: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                height: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
            )
        }
        .frame(minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork)
        .padding(.horizontal, FigmaSize.spacing8.sizeInArtwork)
        .padding(.top, FigmaSize.spacing8.sizeInArtwork)
        .background(Color(theme.colors.background))
        .accessibilityElement(children: .contain)
    }
}
