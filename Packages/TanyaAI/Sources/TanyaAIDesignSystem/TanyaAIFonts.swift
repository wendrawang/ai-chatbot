import UIKit

public struct TanyaAIFonts {
    public let title: UIFont
    public let headline: UIFont
    public let body: UIFont
    public let subheadline: UIFont
    public let footnote: UIFont
    public let caption: UIFont
    public let amount: UIFont
    public let button: UIFont

    public init(
        title: UIFont,
        headline: UIFont,
        body: UIFont,
        subheadline: UIFont,
        footnote: UIFont,
        caption: UIFont,
        amount: UIFont,
        button: UIFont
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
