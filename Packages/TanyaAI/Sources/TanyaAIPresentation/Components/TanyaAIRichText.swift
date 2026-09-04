import SwiftUI

/// Renders a reply's inline styling.
///
/// Styling comes from the closed tag set in `TanyaAIMarkupParser`, never from
/// Markdown: asterisks stay literal, and a response cannot introduce a link,
/// an image, or a heading, because there is no syntax for them to use.
///
/// Runs are concatenated as `Text` rather than assembled into an
/// `AttributedString`: the styles here are a closed set that `Text` already
/// carries, so the extra type would buy nothing.
struct TanyaAIRichText: View {
    let text: String
    let font: Font
    let color: Color

    var body: some View {
        styledText
            .font(font)
            .foregroundColor(color)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var styledText: Text {
        let runs = TanyaAIMarkupParser.runs(from: text)
        guard let first = runs.first else {
            return Text(text)
        }
        return runs.dropFirst().reduce(styled(first)) { result, run in
            result + styled(run)
        }
    }

    private func styled(_ run: TanyaAIMarkupRun) -> Text {
        var fragment = Text(run.text)
        if run.style.isBold {
            fragment = fragment.bold()
        }
        if run.style.isStruckThrough {
            fragment = fragment.strikethrough()
        }
        if let hex = run.style.colorHex, let tint = Color(hex: hex) {
            fragment = fragment.foregroundColor(tint)
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
