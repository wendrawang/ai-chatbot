//
//  RichTextFrame.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import Foundation

struct RichTextFrame
{
    let name: String
    let parameter: String?
    var runs: [RichTextRun] = []
    mutating func append(_ text: String)
    {
        guard let last = runs.indices.last, runs[last].style == RichTextStyle()
        else
        {
            runs.append(RichTextRun(text: text, style: RichTextStyle()))
            return
        }

        runs[last].text.append(contentsOf: text)
    }

    func styledRuns(isClosed: Bool) -> [RichTextRun]
    {
        switch name
        {
        case "bold":
            return apply(runs)
            {
                $0.isBold = true
            }

        case "strike":
            return apply(runs)
            {
                $0.isStruckThrough = true
            }

        case "color":
            return coloredRuns()

        case "link":
            return linkedRuns(isClosed: isClosed)

        default:
            return runs
        }
    }

    private func coloredRuns() -> [RichTextRun]
    {
        guard let parameter
        else
        {
            guard let last = runs.last, let divider = last.text.lastIndex(of: "|")
            else
            {
                return runs
            }

            let value = String(last.text[last.text.index(after: divider)...])
            guard value.count == 6, value.allSatisfy(\.isHexDigit)
            else
            {
                return runs
            }

            let label = RichTextRun(text: String(last.text[..<divider]), style: last.style)
            return apply(Array(runs.dropLast()) + [label])
            {
                $0.color = value
            }
        }

        return apply(runs)
        {
            $0.color = parameter
        }
    }

    private func linkedRuns(isClosed: Bool) -> [RichTextRun]
    {
        guard let parameter
        else
        {
            return legacyLinkedRuns(isClosed: isClosed)
        }

        let target = isClosed ? Self.destination(parameter) : nil
        return apply(runs)
        {
            $0.link = target
        }
    }

    private func legacyLinkedRuns(isClosed: Bool) -> [RichTextRun]
    {
        var target = ""
        var label: [RichTextRun] = []
        var isLabel = false
        for run in runs
        {
            guard !isLabel
            else
            {
                label.append(run)
                continue
            }

            guard let divider = run.text.firstIndex(of: "|")
            else
            {
                target += run.text
                continue
            }

            target += run.text[..<divider]
            label.append(RichTextRun(text: String(run.text[run.text.index(after: divider)...]), style: run.style))
            isLabel = true
        }

        let url = isClosed ? Self.destination(target) : nil
        return apply(label)
        {
            $0.link = url
        }
    }

    static func destination(_ value: String) -> URL?
    {
        guard !value.contains(where: \.isWhitespace), let url = URL(string: value),
              let scheme = url.scheme?.lowercased(),
              !["javascript", "data", "file", "about", "vbscript"].contains(scheme),
              !value.dropFirst(scheme.count + 1).isEmpty
        else
        {
            return nil
        }

        guard ["https", "http"].contains(scheme)
        else
        {
            return url
        }

        return url.host?.isEmpty == false ? url : nil
    }

    private func apply(_ values: [RichTextRun], change: (inout RichTextStyle) -> Void) -> [RichTextRun]
    {
        values.map
        {
            run in
            var result = run
            change(&result.style)
            return result
        }
    }
}

struct RichTextToken
{
    let name: String
    let parameter: String?
    let isClosing: Bool
    let end: String.Index
    init?(source: String, start: String.Index)
    {
        guard let close = source[start...].prefix(4096).firstIndex(of: "]")
        else
        {
            return nil
        }

        let inner = source[source.index(after: start) ..< close]
        isClosing = inner.hasPrefix("/")
        let content = isClosing ? inner.dropFirst() : inner[...]
        let parts = content.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
        guard let first = parts.first, !first.isEmpty, first.allSatisfy(
            {
                $0.isLowercase && $0.isLetter
            })
        else
        {
            return nil
        }

        name = String(first)
        parameter = parts.count == 2 ? String(parts[1]) : nil
        end = source.index(after: close)
    }
}
