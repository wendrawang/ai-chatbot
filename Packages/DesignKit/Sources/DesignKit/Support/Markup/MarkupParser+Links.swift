import Foundation

extension MarkupParser.Frame {
    /// Targets are metadata, including while a response is still streaming.
    /// A malformed target may show its label, but never becomes interactive.
    func linkedRuns(isInteractive: Bool = true) -> [MarkupRun] {
        var target = ""
        var label: [MarkupRun] = []
        var isReadingLabel = false
        for run in runs {
            if isReadingLabel {
                label.append(run)
            } else if let divider = run.text.firstIndex(of: "|") {
                target += run.text[..<divider]
                label.append(
                    MarkupRun(text: String(run.text[run.text.index(after: divider)...]), style: run.style)
                )
                isReadingLabel = true
            } else {
                target += run.text
            }
        }
        guard isReadingLabel else { return [] }
        let destination = isInteractive ? MarkupParser.linkURL(from: target) : nil
        return label.filter { $0.text.isEmpty == false }.map { run in
            var updated = run
            updated.style.linkURL = destination
            return updated
        }
    }
}

extension MarkupParser {
    static func linkURL(from target: String) -> URL? {
        guard target.isEmpty == false,
            target.contains(where: \.isWhitespace) == false,
            let destination = URL(string: target),
            let scheme = destination.scheme?.lowercased(),
            target.dropFirst(scheme.count + 1).contains(where: { $0 != "/" }),
            ["javascript", "data", "file", "about"].contains(scheme) == false
        else { return nil }
        if ["https", "http"].contains(scheme), destination.host?.isEmpty != false {
            return nil
        }
        return destination
    }
}
