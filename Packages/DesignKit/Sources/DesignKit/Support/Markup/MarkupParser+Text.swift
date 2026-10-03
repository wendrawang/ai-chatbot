import Foundation

extension MarkupParser {
    /// Linear fallback for excessive nesting and a readable accessibility label.
    static func plainText(from source: String) -> String {
        var output = ""
        var index = source.startIndex
        while index < source.endIndex {
            if source[index] == "[", let token = Token(source: source, from: index), token.isTag {
                index = token.end
            } else {
                output.append(source[index])
                index = source.index(after: index)
            }
        }
        return output
    }
    static func isValidHex(_ value: String) -> Bool {
        value.count == 6 && value.allSatisfy(\.isHexDigit)
    }

    struct Token {
        let name: String
        let isClosing: Bool
        let isTag: Bool
        let end: String.Index

        init?(source: String, from start: String.Index) {
            // A tag has at most 12 letters plus brackets and an optional '/'.
            // Never rescan the whole remaining message for each literal '['.
            guard let closingBracket = source[start...].prefix(15).firstIndex(of: "]")
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
