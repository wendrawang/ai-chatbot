import SwiftUI

/// One hand-off link - "Lihat Produk Sekarang", "Connect dengan Agent".
///
/// A link rather than a filled button: the destination is elsewhere in the
/// app, and a solid button would promise something happening here.
public struct TanyaAIActionLink: View {
    let button: TanyaAIActionButton
    let onTap: (TanyaAIAction) -> Void
    @Environment(\.tanyaAITheme) private var theme

    public init(
        button: TanyaAIActionButton,
        onTap: @escaping (TanyaAIAction) -> Void
    ) {
        self.button = button
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            onTap(button.action)
        } label: {
            label
        }
        // Both weights stay in the accent colour. Greying the secondary one
        // made an available hand-off read as disabled, which is a worse lie
        // than the two looking similar.
        .foregroundColor(Color(theme.colors.accent))
        .background(TanyaAIOutlinedBackground())
        .accessibilityIdentifier("action.\(button.action.identifier)")
    }

    private var label: some View {
        text
            .font(Font(theme.fonts.button))
            .padding(.horizontal, DesignKitMetrics.Spacing.wide)
            .frame(minHeight: DesignKitMetrics.Size.minimumTapTarget)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Underlined only for the primary weight. `Style` carries no behaviour,
    /// so this is the whole of the difference between the two.
    private var text: Text {
        let base = Text(button.title)
        switch button.style {
        case .primary: return base.underline()
        case .secondary: return base
        }
    }
}
