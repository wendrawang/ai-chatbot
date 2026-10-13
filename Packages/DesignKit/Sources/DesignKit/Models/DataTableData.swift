import CoreGraphics

public enum DataTableAlignment: String, Codable {
    case leading, trailing
}

public struct DataTableColumn: Codable, Equatable {
    public let title: String
    public let alignment: DataTableAlignment
    public let widthWeight: Double

    public init(title: String, alignment: DataTableAlignment = .leading, widthWeight: Double = 1) {
        self.title = title
        self.alignment = alignment
        self.widthWeight = widthWeight
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            title: try container.decode(String.self, forKey: .title),
            alignment: try container.decodeIfPresent(DataTableAlignment.self, forKey: .alignment) ?? .leading,
            widthWeight: try container.decodeIfPresent(Double.self, forKey: .widthWeight) ?? 1
        )
    }
}

public struct DataTableRow: Codable, Equatable {
    public let cells: [String]
    public let isEmphasized: Bool
    /// The leading label may occupy adjacent empty cells, for example a total row.
    public let leadingColumnSpan: Int

    public init(cells: [String], isEmphasized: Bool = false, leadingColumnSpan: Int = 1) {
        self.cells = cells
        self.isEmphasized = isEmphasized
        self.leadingColumnSpan = leadingColumnSpan
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            cells: try container.decode([String].self, forKey: .cells),
            isEmphasized: try container.decodeIfPresent(Bool.self, forKey: .isEmphasized) ?? false,
            leadingColumnSpan: try container.decodeIfPresent(Int.self, forKey: .leadingColumnSpan) ?? 1
        )
    }
}

public enum DataTableValidationError: Error, Equatable {
    case invalidColumnCount(Int)
    case invalidColumnWeight(Int)
    case mismatchedCellCount(row: Int, expected: Int, actual: Int)
    case mismatchedFooterCount(expected: Int, actual: Int)
    case invalidColumnSpan(row: Int, span: Int)
}

/// Validated presentation data. Invalid tables are reported to the caller;
/// neither extra columns nor missing cells are silently discarded.
public struct DataTableData: Codable, Equatable {
    public let columns: [DataTableColumn]
    public let rows: [DataTableRow]
    public let footer: DataTableRow?

    public init(columns: [DataTableColumn], rows: [DataTableRow], footer: DataTableRow? = nil) throws {
        guard (1...DesignKitMetrics.Conversation.maximumTableColumns).contains(columns.count) else {
            throw DataTableValidationError.invalidColumnCount(columns.count)
        }
        for (index, column) in columns.enumerated() {
            guard column.widthWeight.isFinite, column.widthWeight > 0 else {
                throw DataTableValidationError.invalidColumnWeight(index)
            }
        }
        let largestWeight = columns.map(\.widthWeight).max() ?? 1
        for (index, column) in columns.enumerated() where column.widthWeight / largestWeight == 0 {
            throw DataTableValidationError.invalidColumnWeight(index)
        }
        for (index, row) in rows.enumerated() where row.cells.count != columns.count {
            throw DataTableValidationError.mismatchedCellCount(
                row: index, expected: columns.count, actual: row.cells.count
            )
        }
        if let footer = footer, footer.cells.count != columns.count {
            throw DataTableValidationError.mismatchedFooterCount(expected: columns.count, actual: footer.cells.count)
        }
        try Self.validateSpans(rows: rows, columnCount: columns.count)
        if let footer { try Self.validateSpans(rows: [footer], columnCount: columns.count, rowOffset: rows.count) }
        self.columns = columns
        self.rows = rows
        self.footer = footer
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            columns: container.decode([DataTableColumn].self, forKey: .columns),
            rows: container.decode([DataTableRow].self, forKey: .rows),
            footer: container.decodeIfPresent(DataTableRow.self, forKey: .footer)
        )
    }

    /// The same widths apply to the header, every row and the optional footer.
    public func columnWidths(availableWidth: CGFloat, spacing: CGFloat) -> [CGFloat] {
        guard availableWidth.isFinite, spacing.isFinite else { return Array(repeating: 0, count: columns.count) }
        let usableWidth = max(0, availableWidth - max(0, spacing) * CGFloat(columns.count - 1))
        let largestWeight = columns.map(\.widthWeight).max() ?? 1
        let weights = columns.map { $0.widthWeight / largestWeight }
        let totalWeight = weights.reduce(0, +)
        return weights.map { usableWidth * CGFloat($0 / totalWeight) }
    }

    private static func validateSpans(rows: [DataTableRow], columnCount: Int, rowOffset: Int = 0) throws {
        for (index, row) in rows.enumerated() {
            guard (1...columnCount).contains(row.leadingColumnSpan),
                row.cells.dropFirst().prefix(row.leadingColumnSpan - 1).allSatisfy(\.isEmpty)
            else {
                throw DataTableValidationError.invalidColumnSpan(row: rowOffset + index, span: row.leadingColumnSpan)
            }
        }
    }
}
