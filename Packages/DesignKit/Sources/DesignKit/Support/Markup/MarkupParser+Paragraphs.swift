import Foundation

struct MarkupParagraph: Equatable {
    let marker: String?
    var runs: [MarkupRun]
}

extension MarkupParser {
    /// Line breaks preserve styles. Explicitly indented continuation lines
    /// stay inside the previous list item, so wrapping has a hanging indent.
    static func paragraphs(from runs: [MarkupRun]) -> [MarkupParagraph] {
        var lines: [[MarkupRun]] = [[]]
        for run in runs {
            let pieces = run.text.components(separatedBy: "\n")
            for (offset, piece) in pieces.enumerated() {
                if offset > 0 { lines.append([]) }
                if piece.isEmpty == false {
                    lines[lines.count - 1].append(MarkupRun(text: piece, style: run.style))
                }
            }
        }
        return listParagraphs(from: lines)
    }

    private static func listParagraphs(from lines: [[MarkupRun]]) -> [MarkupParagraph] {
        var paragraphs: [MarkupParagraph] = []
        for line in lines {
            let text = line.map(\.text).joined()
            if let prefix = listPrefix(in: text) {
                paragraphs.append(
                    MarkupParagraph(marker: prefix.marker, runs: dropping(prefix.count, from: line))
                )
            } else if text.prefix(2).allSatisfy({ $0 == " " || $0 == "\t" }), text.count >= 2,
                let last = paragraphs.indices.last, paragraphs[last].marker != nil
            {
                let indentation = text.prefix { $0 == " " || $0 == "\t" }.count
                paragraphs[last].runs.append(MarkupRun(text: "\n", style: MarkupStyle()))
                paragraphs[last].runs += dropping(indentation, from: line)
            } else {
                paragraphs.append(MarkupParagraph(marker: nil, runs: line))
            }
        }
        return paragraphs
    }

    private static func listPrefix(in text: String) -> (marker: String, count: Int)? {
        let indentation = text.prefix { $0 == " " || $0 == "\t" }.count
        let remaining = text.dropFirst(indentation)
        if remaining.hasPrefix("•") || remaining.hasPrefix("- ") {
            let length = remaining.hasPrefix("•") ? 1 : 2
            let spaces = remaining.dropFirst(length).prefix { $0 == " " || $0 == "\t" }.count
            return ("•", indentation + length + spaces)
        }
        let digits = remaining.prefix(3).prefix { $0.isASCII && $0.isNumber }
        guard digits.isEmpty == false else { return nil }
        let tail = remaining.dropFirst(digits.count)
        guard tail.hasPrefix(". ") || tail.hasPrefix(") ") else { return nil }
        let spaces = tail.dropFirst().prefix { $0 == " " || $0 == "\t" }.count
        return (String(digits) + String(tail.prefix(1)), indentation + digits.count + 1 + spaces)
    }

    private static func dropping(_ count: Int, from runs: [MarkupRun]) -> [MarkupRun] {
        var remaining = count
        return runs.compactMap { run in
            let removed = min(remaining, run.text.count)
            remaining -= removed
            let text = String(run.text.dropFirst(removed))
            return text.isEmpty ? nil : MarkupRun(text: text, style: run.style)
        }
    }
}
