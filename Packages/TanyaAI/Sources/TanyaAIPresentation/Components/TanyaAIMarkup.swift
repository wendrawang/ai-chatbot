import Foundation

/// Inline styling a reply may carry.
///
/// The wire format is a closed set of bracket tags, not Markdown. Asterisks
/// are ordinary characters in banking copy - masked cards, footnote markers -
/// and a closed set means a response can only reach the styles listed here.
///
///     [bold]wen[/bold]
///     [strike]wen[/strike]
///     [color]wen|25C36B[/color]
struct TanyaAIMarkupStyle: Equatable {
    var isBold = false
    var isStruckThrough = false
    var colorHex: String?

    var isPlain: Bool {
        isBold == false && isStruckThrough == false && colorHex == nil
    }
}

/// One stretch of text sharing the same styling.
struct TanyaAIMarkupRun: Equatable {
    let text: String
    var style: TanyaAIMarkupStyle
}

enum TanyaAIMarkupTag: String {
    case bold
    case strike
    case color
}

/// Turns tagged text into styled runs.
///
/// Rules, all of them deliberate:
///
/// - **Unknown tags are dropped, their content is kept.** A backend that ships
///   a new tag before the app supports it degrades to plain text instead of
///   showing markup to the customer.
/// - **Unclosed tags still style the remainder.** Text arrives in chunks, so
///   `[bold]wen` is bold while the rest is still on its way.
/// - **A half-arrived tag at the end is hidden.** `wen [bo` renders as `wen `
///   rather than flashing the raw tag, and completes on the next chunk.
/// - **Anything else stays literal.** A stray `[` is just a bracket.
enum TanyaAIMarkupParser {
    static func runs(from source: String) -> [TanyaAIMarkupRun] {
        var frames: [Frame] = [Frame(tag: nil)]
        var buffer = ""
        var index = source.startIndex

        while index < source.endIndex {
            guard source[index] == "[" else {
                buffer.append(source[index])
                index = source.index(after: index)
                continue
            }

            guard let token = Token(source: source, from: index) else {
                // No closing bracket yet: a tag still arriving. Drop the
                // fragment; the next chunk completes it.
                break
            }

            guard token.isTag else {
                buffer.append(source[index])
                index = source.index(after: index)
                continue
            }

            frames[frames.count - 1].append(text: buffer)
            buffer = ""
            index = token.end

            if token.isClosing {
                close(token.name, in: &frames)
            } else {
                frames.append(Frame(tag: TanyaAIMarkupTag(rawValue: token.name)))
            }
        }

        frames[frames.count - 1].append(text: buffer)
        while frames.count > 1 {
            let frame = frames.removeLast()
            frames[frames.count - 1].append(runs: frame.styledRuns())
        }
        return frames[0].runs.filter { $0.text.isEmpty == false }
    }

    private static func close(_ name: String, in frames: inout [Frame]) {
        guard frames.count > 1 else {
            return
        }
        let frame = frames.removeLast()
        guard frame.tag?.rawValue == name || frame.tag == nil else {
            // Mismatched close: keep the content, forget the styling.
            frames[frames.count - 1].append(runs: frame.runs)
            return
        }
        frames[frames.count - 1].append(runs: frame.styledRuns())
    }

    private struct Frame {
        let tag: TanyaAIMarkupTag?
        var runs: [TanyaAIMarkupRun] = []

        mutating func append(text: String) {
            guard text.isEmpty == false else {
                return
            }
            runs.append(
                TanyaAIMarkupRun(text: text, style: TanyaAIMarkupStyle())
            )
        }

        mutating func append(runs newRuns: [TanyaAIMarkupRun]) {
            runs.append(contentsOf: newRuns)
        }

        /// Applies this frame's tag to everything it collected.
        func styledRuns() -> [TanyaAIMarkupRun] {
            guard let tag else {
                return runs
            }
            switch tag {
            case .bold:
                return runs.map { apply($0) { $0.isBold = true } }
            case .strike:
                return runs.map { apply($0) { $0.isStruckThrough = true } }
            case .color:
                return colouredRuns()
            }
        }

        /// `[color]wen|25C36B[/color]` carries its value inside the element,
        /// after the last pipe, so it is stripped before the text is shown.
        private func colouredRuns() -> [TanyaAIMarkupRun] {
            guard var last = runs.last,
                  let pipe = last.text.lastIndex(of: "|") else {
                return runs
            }
            let hex = String(last.text[last.text.index(after: pipe)...])
            guard TanyaAIMarkupParser.isValidHex(hex) else {
                return runs
            }
            last = TanyaAIMarkupRun(
                text: String(last.text[..<pipe]),
                style: last.style
            )
            var updated = Array(runs.dropLast()) + [last]
            updated = updated.map { run in
                apply(run) { style in
                    if style.colorHex == nil {
                        style.colorHex = hex
                    }
                }
            }
            return updated.filter { $0.text.isEmpty == false }
        }

        private func apply(
            _ run: TanyaAIMarkupRun,
            _ change: (inout TanyaAIMarkupStyle) -> Void
        ) -> TanyaAIMarkupRun {
            var updated = run
            change(&updated.style)
            return updated
        }
    }

    static func isValidHex(_ value: String) -> Bool {
        value.count == 6 && value.allSatisfy(\.isHexDigit)
    }

    private struct Token {
        let name: String
        let isClosing: Bool
        let isTag: Bool
        let end: String.Index

        init?(source: String, from start: String.Index) {
            guard let closingBracket = source[start...].firstIndex(of: "]")
            else {
                return nil
            }
            let inner = source[source.index(after: start)..<closingBracket]
            let isClosing = inner.hasPrefix("/")
            let name = String(isClosing ? inner.dropFirst() : inner)
            self.name = name
            self.isClosing = isClosing
            self.end = source.index(after: closingBracket)
            self.isTag = name.isEmpty == false
                && name.count <= 12
                && name.allSatisfy { $0.isLowercase && $0.isLetter }
        }
    }
}
