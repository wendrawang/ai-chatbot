public struct TanyaAIFinancialListPayload: Equatable {
    public enum Style: String, Equatable {
        case paidBills
        case incoming
        case holdings
    }

    public let title: String
    public let style: Style
    public let rows: [TanyaAIFinancialListRow]
    public let totalLabel: String?
    public let totalValue: String?
    public let totalCaption: String?
    public let footnote: String?

    public init(
        title: String,
        style: Style,
        rows: [TanyaAIFinancialListRow],
        totalLabel: String? = nil,
        totalValue: String? = nil,
        totalCaption: String? = nil,
        footnote: String? = nil
    ) {
        self.title = title
        self.style = style
        self.rows = rows
        self.totalLabel = totalLabel
        self.totalValue = totalValue
        self.totalCaption = totalCaption
        self.footnote = footnote
    }
}

public struct TanyaAIFinancialListRow: Equatable {
    public enum Tone: String, Equatable {
        case neutral
        case positive
    }

    public let title: String
    public let subtitle: String?
    public let value: String
    public let detail: String?
    public let tone: Tone

    public init(
        title: String,
        subtitle: String? = nil,
        value: String,
        detail: String? = nil,
        tone: Tone = .neutral
    ) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.detail = detail
        self.tone = tone
    }
}
