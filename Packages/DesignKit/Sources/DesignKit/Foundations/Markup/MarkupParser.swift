//
//  MarkupParser.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import Foundation

/// Gaya inline satu potongan teks.
struct MarkupStyle: Equatable {
    var isBold = false
    var isStruckThrough = false
    var colorHex: String?
    var link: URL?
}

/// Potongan teks dengan gaya yang sama.
struct MarkupRun: Equatable {
    var text: String
    var style: MarkupStyle
}

/// Tag tertutup yang didukung; bukan Markdown, karena `*` lazim di copy perbankan.
///
///     [bold]teks[/bold]   [strike]teks[/strike]
///     [color]teks|25C36B[/color]   [link]label|https://… atau ocbcid://… atau tel:…[/link]
///
/// - Tag tak dikenal dibuang, isinya tetap tampil.
/// - Tag yang belum ditutup tetap memberi gaya pada sisa teks (aman saat streaming).
/// - Tag yang baru datang separuh di akhir (`teks [bo`) disembunyikan sampai lengkap.
/// - Target link yang tidak aman (`javascript:`, `file:`, `data:`) tidak bisa diketuk.
enum MarkupParser {
    enum Tag: String {
        case bold, strike, color, link
    }

    static func runs(from source: String) -> [MarkupRun] {
        var state = State()
        var index = source.startIndex
        while index < source.endIndex {
            let character = source[index]
            guard character == MarkupSyntax.open, let token = Token(source: source, at: index) else {
                if character == MarkupSyntax.open, Token.isPartial(source[index...]) { break }
                state.append(text: String(character))
                index = source.index(after: index)
                continue
            }
            index = token.end
            guard let tag = token.tag else { continue }
            if token.isClosing { state.close(tag) } else { state.open(tag) }
        }
        return state.finish()
    }

    static func safeLink(_ target: String) -> URL? {
        guard !target.isEmpty, !target.contains(where: \.isWhitespace),
            let url = URL(string: target), let scheme = url.scheme?.lowercased(),
            !MarkupSyntax.blockedSchemes.contains(scheme)
        else { return nil }
        return url
    }
}

private extension MarkupParser {
    /// Teks tingkat atas ditambah tumpukan tag yang sedang terbuka.
    struct State {
        var root = Frame(tag: nil)
        var stack: [Frame] = []

        mutating func append(text: String) {
            if stack.isEmpty { root.append(text) } else { stack[stack.index(before: stack.endIndex)].append(text) }
        }

        mutating func append(runs: [MarkupRun]) {
            if stack.isEmpty { root.runs += runs } else { stack[stack.index(before: stack.endIndex)].runs += runs }
        }

        mutating func open(_ tag: Tag) {
            stack.append(Frame(tag: tag))
        }

        /// Penutup tanpa pembuka diabaikan; penutup tag luar ikut menutup tag di dalamnya.
        mutating func close(_ tag: Tag) {
            guard stack.contains(where: { $0.tag == tag }) else { return }
            while let frame = stack.popLast() {
                append(runs: frame.finished(isClosed: frame.tag == tag))
                if frame.tag == tag { return }
            }
        }

        mutating func finish() -> [MarkupRun] {
            while let frame = stack.popLast() { append(runs: frame.finished(isClosed: false)) }
            return root.runs.filter { !$0.text.isEmpty }
        }
    }
}
