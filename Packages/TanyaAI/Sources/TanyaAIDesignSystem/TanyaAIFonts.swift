import SwiftUI

public struct TanyaAIFonts {
    public let title: Font
    public let headline: Font
    public let body: Font
    public let subheadline: Font
    public let footnote: Font
    public let caption: Font
    public let amount: Font
    public let button: Font

    public init(
        title: Font,
        headline: Font,
        body: Font,
        subheadline: Font,
        footnote: Font,
        caption: Font,
        amount: Font,
        button: Font
    ) {
        self.title = title
        self.headline = headline
        self.body = body
        self.subheadline = subheadline
        self.footnote = footnote
        self.caption = caption
        self.amount = amount
        self.button = button
    }
}
