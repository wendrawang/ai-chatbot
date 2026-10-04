import SwiftUI

/// One hand-off link - "Lihat Produk Sekarang", "Connect dengan Agent".
///
/// A link rather than a filled button: the destination is elsewhere in the
/// app, and a solid button would promise something happening here.
public struct ActionLink: View {
    let title: String
    let isUnderlined: Bool
    let onTap: () -> Void
    @Environment(\.theme) private var theme

    public init(
        title: String,
        isUnderlined: Bool = true,
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.isUnderlined = isUnderlined
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            onTap()
        } label: {
            label
        }
        // Both weights stay in the accent colour. Greying the secondary one
        // made an available hand-off read as disabled, which is a worse lie
        // than the two looking similar.
        .foregroundColor(Color(theme.colors.accent))
        .background(OutlinedBackground())
    }

    private var label: some View {
        text
            .designFont(.button)
            .padding(.horizontal, DesignKitMetrics.Spacing.wide.sizeInArtwork)
            .frame(minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Underlined only for the primary weight. `Style` carries no behaviour,
    /// so this is the whole of the difference between the two.
    private var text: Text {
        let base = Text(title)
        return isUnderlined ? base.underline() : base
    }
}
