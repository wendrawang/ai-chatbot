import SwiftUI

/// Header content stays injectable: a product logo, account or other item can
/// share the same summary surface without a configuration of unrelated flags.
public struct SummaryCard<Header: View>: View {
    @Environment(\.theme)
    private var theme
    private let fields: [SummaryField]
    private let header: Header

    public init(fields: [SummaryField], @ViewBuilder header: () -> Header) {
        self.fields = fields
        self.header = header()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing16.sizeInArtwork) {
            header
            divider
            ForEach(fields.indices, id: \.self) { index in
                if fields[index].isEmphasized { divider }
                row(for: fields[index])
            }
        }
        .padding(FigmaSize.spacing16.sizeInArtwork)
        .background(Color(theme.colors.surface))
        .cornerRadius(DesignKitMetrics.Conversation.summaryRadius.sizeInArtwork)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("summary.card")
    }

    private func row(for field: SummaryField) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: FigmaSize.spacing16.sizeInArtwork) {
            Text(field.label)
                .fontWeight(field.isEmphasized ? .semibold : .regular)
                .foregroundColor(Color(field.isEmphasized ? theme.colors.primaryText : theme.colors.secondaryText))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(field.value)
                .fontWeight(field.isEmphasized ? .semibold : .regular)
                .foregroundColor(Color(theme.colors.primaryText))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .designFont(.subheadline)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(theme.colors.divider))
            .frame(height: DesignKitMetrics.Stroke.divider.strokeInArtwork)
            .accessibilityHidden(true)
    }
}
