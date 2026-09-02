import SwiftUI

/// Renders inline emphasis inside one bubble.
///
/// Answers are rarely one flat sentence: they carry labelled steps such as
/// `**Tentukan Tujuan Investasi**: ...`, and the label has to stand out
/// without splitting the reply into separate bubbles.
///
/// Only inline syntax is interpreted - bold, italic, inline code - and line
/// breaks are preserved, so a reply cannot smuggle headings, images, or links
/// that would change the layout the package controls.
///
/// While text is still streaming an unclosed `**` simply renders as literal
/// asterisks and resolves itself as soon as the closing pair arrives.
struct TanyaAIRichText: View {
    let text: String
    let font: Font
    let color: Color

    var body: some View {
        Text(attributedText)
            .font(font)
            .foregroundColor(color)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var attributedText: AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        guard let parsed = try? AttributedString(
            markdown: text,
            options: options
        ) else {
            return AttributedString(text)
        }
        return parsed
    }
}
