import SwiftUI

/// A generic summary with an explicit confirmation intent; authorization belongs to the caller.
public struct ConfirmationCard: View {
    private let title: String
    private let fields: [KeyValue]
    private let confirmLabel: String
    private let onConfirm: () -> Void
    @Environment(\.theme) private var theme

    public init(title: String, fields: [KeyValue], confirmLabel: String, onConfirm: @escaping () -> Void) {
        self.title = title
        self.fields = fields
        self.confirmLabel = confirmLabel
        self.onConfirm = onConfirm
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignKitMetrics.Spacing.wide.sizeInArtwork) {
            Text(title).designFont(.headline)
            ForEach(fields.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline, spacing: DesignKitMetrics.Spacing.regular.sizeInArtwork) {
                    Text(fields[index].label).foregroundColor(Color(theme.colors.secondaryText))
                    Spacer(minLength: DesignKitMetrics.Spacing.compact.sizeInArtwork)
                    Text(fields[index].value).multilineTextAlignment(.trailing)
                }
                .designFont(.body)
                .fixedSize(horizontal: false, vertical: true)
            }
            Button(action: onConfirm) {
                Text(confirmLabel).designFont(.button)
                    .frame(maxWidth: .infinity, minHeight: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork)
            }
            .buttonStyle(DesignButtonStyle())
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .padding(DesignKitMetrics.Spacing.wide.sizeInArtwork)
        .background(Color(theme.colors.surface))
        .clipShape(RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.card.sizeInArtwork))
        .frame(maxWidth: DesignKitMetrics.Size.cardMaximumWidth.sizeInArtwork)
    }
}
