import SwiftUI

/// A generic summary with an explicit confirmation intent; authorization belongs to the caller.
public struct ConfirmationCard: View {
    private let title: String
    private let fields: [KeyValue]
    private let confirmLabel: String
    private let onConfirm: () -> Void
    @Environment(\.theme) private var theme
    @Environment(\.artwork) private var artwork

    public init(title: String, fields: [KeyValue], confirmLabel: String, onConfirm: @escaping () -> Void) {
        self.title = title
        self.fields = fields
        self.confirmLabel = confirmLabel
        self.onConfirm = onConfirm
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: artwork.size(DesignKitMetrics.Spacing.wide)) {
            Text(title).designFont(.headline)
            ForEach(fields.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline, spacing: artwork.size(DesignKitMetrics.Spacing.regular)) {
                    Text(fields[index].label).foregroundColor(Color(theme.colors.secondaryText))
                    Spacer(minLength: artwork.size(DesignKitMetrics.Spacing.compact))
                    Text(fields[index].value).multilineTextAlignment(.trailing)
                }
                .designFont(.body)
                .fixedSize(horizontal: false, vertical: true)
            }
            Button(action: onConfirm) {
                Text(confirmLabel).designFont(.button)
                    .frame(maxWidth: .infinity, minHeight: artwork.tapTarget())
            }
            .buttonStyle(DesignButtonStyle())
        }
        .foregroundColor(Color(theme.colors.primaryText))
        .padding(artwork.size(DesignKitMetrics.Spacing.wide))
        .background(Color(theme.colors.surface))
        .clipShape(RoundedRectangle(cornerRadius: artwork.size(DesignKitMetrics.Radius.card)))
        .frame(maxWidth: artwork.size(DesignKitMetrics.Size.cardMaximumWidth))
    }
}
