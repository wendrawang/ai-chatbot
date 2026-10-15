import SwiftUI

/// A native table with at most three columns and one shared width allocation.
/// It expands vertically with wrapping cells and never owns a nested scroll view.
public struct DataTable: View {
    @Environment(\.theme)
    private var theme
    @Environment(\.sizeCategory)
    private var sizeCategory
    @State
    private var availableWidth: CGFloat = 0
    private let data: DataTableData

    public init(data: DataTableData) {
        self.data = data
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if sizeCategory.isAccessibilityCategory {
                stackedContent
            } else {
                tabularContent
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(widthReader)
        .onPreferenceChange(TableWidthPreference.self) { width in
            if width.isFinite, abs(width - availableWidth) > DesignKitMetrics.Layout.measurementTolerance {
                availableWidth = width
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("data.table")
    }

    private var tabularContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            row(cells: data.columns.map(\.title), isEmphasized: true, isHeader: true)
            divider
            ForEach(data.rows.indices, id: \.self) { index in
                row(
                    cells: data.rows[index].cells, isEmphasized: data.rows[index].isEmphasized,
                    leadingColumnSpan: data.rows[index].leadingColumnSpan
                )
                divider
            }
            if let footer = data.footer {
                row(cells: footer.cells, isEmphasized: true, leadingColumnSpan: footer.leadingColumnSpan)
            }
        }
    }

    /// Keep logical columns intact, but make every value readable with accessibility text sizes.
    private var stackedContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(data.rows.indices, id: \.self) { index in
                stackedRow(data.rows[index])
                divider
            }
            if let footer = data.footer {
                VStack(alignment: .leading, spacing: FigmaSize.spacing8.scaledToArtwork) {
                    ForEach(visibleColumns(span: footer.leadingColumnSpan), id: \.self) { index in
                        Text(footer.cells[index]).fontWeight(.semibold).designFont(.subheadline)
                    }
                }
                .padding(.vertical, FigmaSize.spacing8.scaledToArtwork)
            }
        }
    }

    private func stackedRow(_ row: DataTableRow) -> some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing16.scaledToArtwork) {
            ForEach(visibleColumns(span: row.leadingColumnSpan), id: \.self) { index in
                VStack(alignment: .leading, spacing: FigmaSize.spacing4.scaledToArtwork) {
                    Text(data.columns[index].title)
                        .designFont(.footnote)
                        .foregroundColor(Color(theme.colors.secondaryText))
                    Text(row.cells[index])
                        .fontWeight(row.isEmphasized ? .semibold : .regular)
                        .designFont(.subheadline)
                        .foregroundColor(Color(theme.colors.primaryText))
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
            }
        }
        .padding(.vertical, FigmaSize.spacing16.scaledToArtwork)
    }

    private func row(
        cells: [String], isEmphasized: Bool, isHeader: Bool = false, leadingColumnSpan: Int = 1
    ) -> some View {
        let widths = data.columnWidths(availableWidth: availableWidth, spacing: FigmaSize.spacing8.scaledToArtwork)
        let indices = visibleColumns(span: leadingColumnSpan)
        return HStack(alignment: .top, spacing: FigmaSize.spacing8.scaledToArtwork) {
            ForEach(indices, id: \.self) { index in
                Text(cells[index])
                    .fontWeight(isEmphasized ? .semibold : .regular)
                    .designFont(isHeader ? .footnote : .subheadline)
                    .monospacedDigit()
                    .foregroundColor(Color(theme.colors.primaryText))
                    .multilineTextAlignment(data.columns[index].alignment == .trailing ? .trailing : .leading)
                    .frame(
                        width: cellWidth(index: index, widths: widths, leadingColumnSpan: leadingColumnSpan),
                        alignment: data.columns[index].alignment == .trailing ? .trailing : .leading
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: availableWidth > 0 ? nil : .infinity, alignment: .leading)
                    .accessibilityLabel(accessibilityLabel(cells: cells, index: index, isHeader: isHeader))
            }
        }
        .padding(.vertical, FigmaSize.spacing8.scaledToArtwork)
    }

    private func visibleColumns(span: Int) -> [Int] {
        data.columns.indices.filter { $0 == 0 || $0 >= span }
    }

    private func cellWidth(index: Int, widths: [CGFloat], leadingColumnSpan: Int) -> CGFloat? {
        guard availableWidth > 0 else { return nil }
        if index == 0 {
            return widths.prefix(leadingColumnSpan).reduce(0, +)
                + FigmaSize.spacing8.scaledToArtwork * CGFloat(leadingColumnSpan - 1)
        }
        return widths[index]
    }

    private func accessibilityLabel(cells: [String], index: Int, isHeader: Bool) -> String {
        isHeader ? cells[index] : "\(data.columns[index].title): \(cells[index])"
    }

    private var divider: some View {
        Rectangle()
            .fill(Color(theme.colors.divider))
            .frame(height: DesignKitMetrics.Stroke.divider.strokeInArtwork)
            .accessibilityHidden(true)
    }

    private var widthReader: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: TableWidthPreference.self, value: geometry.size.width)
        }
    }
}

private struct TableWidthPreference: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
