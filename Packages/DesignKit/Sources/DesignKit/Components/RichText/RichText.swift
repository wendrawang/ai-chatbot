import SwiftUI

/// Renders a reply's inline styling.
///
/// Native attributed text preserves inline link hit testing and styles.
/// List markers are separate from their body so wrapped lines stay aligned.
struct RichText: View {
    @Environment(\.lineSpacing)
    private var lineSpacing
    let runs: [MarkupRun]
    let font: Font
    let color: Color
    var linkColor: Color?
    var onLink: ((URL) -> Void)?

    var body: some View {
        content
            .font(font)
            .foregroundColor(color)
            .fixedSize(horizontal: false, vertical: true)
            .environment(\.openURL, linkAction)
    }

    var linkAction: OpenURLAction {
        OpenURLAction { destination in
            guard let onLink else { return .discarded }
            onLink(destination)
            return .handled
        }
    }

    @ViewBuilder
    private var content: some View {
        let paragraphs = MarkupParser.paragraphs(from: runs)
        if paragraphs.contains(where: { $0.marker != nil }) {
            VStack(alignment: .leading, spacing: lineSpacing) {
                ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                    row(for: paragraph)
                }
            }
        } else {
            // Ordinary multiline text remains one native Text instead of one
            // view per line. Explicit list items need the separate marker/body layout.
            Text(attributedText(for: runs))
        }
    }

    @ViewBuilder
    private func row(for paragraph: MarkupParagraph) -> some View {
        if let marker = paragraph.marker {
            HStack(alignment: .firstTextBaseline, spacing: FigmaSize.spacingSmall.sizeInArtwork) {
                Text(marker)
                    .fixedSize()
                    .accessibilityHidden(true)
                Text(attributedText(for: paragraph.runs))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            Text(paragraph.runs.isEmpty ? AttributedString(" ") : attributedText(for: paragraph.runs))
        }
    }

    func attributedText(for runs: [MarkupRun]) -> AttributedString {
        runs.reduce(into: AttributedString()) { result, run in
            result.append(styled(run))
        }
    }

    private func styled(_ run: MarkupRun) -> AttributedString {
        var fragment = AttributedString(run.text)
        var resolvedFont = font
        if run.style.isBold {
            resolvedFont = resolvedFont.bold()
        }
        if run.style.isItalic {
            resolvedFont = resolvedFont.italic()
        }
        fragment.font = resolvedFont
        if run.style.isUnderlined {
            fragment.underlineStyle = .single
        }
        if run.style.isStruckThrough {
            fragment.strikethroughStyle = .single
        }
        if let destination = run.style.linkURL {
            fragment.link = destination
            fragment.foregroundColor = linkColor ?? color
            fragment.underlineStyle = .single
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
        guard MarkupParser.isValidHex(hex),
            let value = UInt32(hex, radix: 16)
        else {
            return nil
        }
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
