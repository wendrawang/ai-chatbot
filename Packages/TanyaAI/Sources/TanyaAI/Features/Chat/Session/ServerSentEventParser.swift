//
//  ServerSentEventParser.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import Foundation

/// Menyusun baris SSE menjadi frame. Frame selesai pada baris kosong, atau pada baris `id:`/`event:`
/// berikutnya setelah `data:` karena host boleh membuang baris kosong. Komentar (`: keepalive`) diabaikan.
struct ServerSentEventParser {
    private var eventID: String?
    private var name: String?
    private var data: String?

    /// Satu baris tanpa newline; mengembalikan frame yang selesai karena baris ini, bila ada.
    mutating func consume(_ line: String) -> ServerSentEvent? {
        let line = line.trimmingCharacters(in: .newlines)
        if line.isEmpty {
            return flush()
        }
        if line.hasPrefix(ChatWire.commentPrefix) {
            return nil
        }
        let isNextFrame = data != nil && (line.hasPrefix(ChatWire.idField) || line.hasPrefix(ChatWire.eventField))
        let completed = isNextFrame ? flush() : nil
        if let value = Self.value(of: line, field: ChatWire.idField) {
            eventID = value
        } else if let value = Self.value(of: line, field: ChatWire.eventField) {
            name = value
        } else if let value = Self.value(of: line, field: ChatWire.dataField) {
            data = data.map { $0 + ChatWire.lineBreak + value } ?? value
        }
        return completed
    }

    /// Frame yang belum ditutup baris kosong, misalnya saat stream berakhir.
    mutating func flush() -> ServerSentEvent? {
        defer { self = Self() }
        guard let data else { return nil }
        return ServerSentEvent(id: eventID, name: name ?? ChatWire.Event.message, data: data)
    }
}

// MARK: - Helpers

private extension ServerSentEventParser {
    static func value(of line: String, field: String) -> String? {
        guard line.hasPrefix(field) else { return nil }
        let value = line.dropFirst(field.count)
        return String(value.hasPrefix(ChatWire.fieldValueSpace) ? value.dropFirst() : value)
    }
}
