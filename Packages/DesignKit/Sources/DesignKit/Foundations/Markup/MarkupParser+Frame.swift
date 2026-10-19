//
//  MarkupParser+Frame.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import Foundation

extension MarkupParser {
    /// Isi satu tag yang sedang terbuka.
    struct Frame {
        let tag: Tag?
        var runs: [MarkupRun] = []

        mutating func append(_ text: String) {
            if let last = runs.last, last.style == MarkupStyle() {
                runs[runs.index(before: runs.endIndex)].text += text
            } else {
                runs.append(MarkupRun(text: text, style: MarkupStyle()))
            }
        }

        /// Terapkan gaya tag pada isinya. Color/link membaca `label|nilai`. Selama tag belum
        /// ditutup (masih streaming) label tampil polos: target separuh tidak pernah bisa diketuk.
        func finished(isClosed: Bool) -> [MarkupRun] {
            switch tag {
            case .bold: return styled(runs) { $0.isBold = true }
            case .strike: return styled(runs) { $0.isStruckThrough = true }
            case .color:
                let (label, value) = split()
                return isClosed ? styled(label) { $0.colorHex = $0.colorHex ?? value } : label
            case .link:
                let (label, value) = split()
                let destination = isClosed ? value.flatMap(MarkupParser.safeLink) : nil
                return styled(label) { $0.link = destination }
            case nil: return runs
            }
        }

        private func styled(_ runs: [MarkupRun], change: (inout MarkupStyle) -> Void) -> [MarkupRun] {
            runs.map { run in
                var run = run
                change(&run.style)
                return run
            }
        }

        /// Pisahkan label dan nilai pada `|` terakhir. Nilai dibaca sebagai teks polos.
        private func split() -> (label: [MarkupRun], value: String?) {
            guard let runIndex = runs.lastIndex(where: { $0.text.contains(MarkupSyntax.divider) }),
                let divider = runs[runIndex].text.lastIndex(of: MarkupSyntax.divider)
            else { return (runs, nil) }
            let run = runs[runIndex]
            var label = Array(runs[..<runIndex])
            let head = run.text[..<divider]
            if !head.isEmpty { label.append(MarkupRun(text: String(head), style: run.style)) }
            let rest = runs[runs.index(after: runIndex)...].map(\.text).joined()
            let value = String(run.text[run.text.index(after: divider)...]) + rest
            return (label, value.trimmingCharacters(in: .whitespaces))
        }
    }

    /// Satu `[tag]` atau `[/tag]` lengkap. Nama tak dikenal tetap dibaca agar bisa dibuang.
    struct Token {
        let tag: Tag?
        let isClosing: Bool
        let end: String.Index

        init?(source: String, at start: String.Index) {
            guard let close = source[start...].firstIndex(of: MarkupSyntax.close) else { return nil }
            var name = source[source.index(after: start)..<close]
            isClosing = name.first == MarkupSyntax.closingMark
            if isClosing { name = name.dropFirst() }
            guard !name.isEmpty, name.allSatisfy({ $0.isLetter && $0.isLowercase }) else { return nil }
            tag = Tag(rawValue: String(name))
            end = source.index(after: close)
        }

        /// `[`, `[bo`, `[/li` di akhir teks: kemungkinan tag yang masih streaming.
        static func isPartial(_ rest: Substring) -> Bool {
            guard !rest.contains(MarkupSyntax.close) else { return false }
            var name = rest.dropFirst()
            if name.first == MarkupSyntax.closingMark { name = name.dropFirst() }
            return name.allSatisfy { $0.isLetter && $0.isLowercase }
        }
    }
}
