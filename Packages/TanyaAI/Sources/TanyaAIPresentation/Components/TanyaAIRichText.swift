import SwiftUI

/// Renders a reply's inline styling.
///
/// Styling comes from the closed tag set in `TanyaAIMarkupParser`, never from
/// Markdown: asterisks stay literal, and a response cannot introduce a link,
/// an image, or a heading, because there is no syntax for them to use.
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
        let runs = TanyaAIMarkupParser.runs(from: text)
        guard runs.isEmpty == false else {
            return AttributedString(text)
        }
        return runs.reduce(into: AttributedString()) { result, run in
            result.append(attributed(run))
        }
    }

    private func attributed(_ run: TanyaAIMarkupRun) -> AttributedString {
        var fragment = AttributedString(run.text)
        if run.style.isBold {
            fragment.font = font.bold()
        }
        if run.style.isStruckThrough {
            fragment.strikethroughStyle = .single
        }
        if let hex = run.style.colorHex, let tint = Color(hex: hex) {
            fragment.foregroundColor = tint
        }
        return fragment
    }
}

extension Color {
    /// Six-digit RRGGBB, as sent by `[color]text|RRGGBB[/color]`.
    init?(hex: String) {
        guard TanyaAIMarkupParser.isValidHex(hex),
              let value = UInt32(hex, radix: 16) else {
            return nil
        }
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
