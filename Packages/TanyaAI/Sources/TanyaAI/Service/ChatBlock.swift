//
//  ChatBlock.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import Foundation

/// Blok jawaban berurutan. Dipakai sama untuk event `blocks` dan hasil mapping intent.
enum ChatBlock: Equatable, Decodable {
    case text(String)
    case table(TableBlock)
    case options(OptionsBlock)
    case media(MediaBlock)
    case actions([ActionItem])
    case suggestions([ActionItem])
    /// Jenis yang belum didukung app; dilewati agar backend boleh menambah blok baru.
    case unsupported

    private enum Kind: String, Decodable {
        case text, table, options, media, actions, suggestions
    }

    private enum CodingKeys: String, CodingKey {
        case type, text, items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try? container.decode(Kind.self, forKey: .type) {
        case .text: self = .text(try container.decode(String.self, forKey: .text))
        case .table: self = .table(try TableBlock(from: decoder))
        case .options: self = .options(try OptionsBlock(from: decoder))
        case .media: self = .media(try MediaBlock(from: decoder))
        case .actions: self = .actions(try container.decode([ActionItem].self, forKey: .items))
        case .suggestions: self = .suggestions(try container.decode([ActionItem].self, forKey: .items))
        case nil: self = .unsupported
        }
    }
}

struct TableBlock: Equatable, Decodable {
    struct Column: Equatable, Decodable {
        let title: String
        let isTrailing: Bool?
    }

    struct Footer: Equatable, Decodable {
        let label: String
        let value: String
    }

    let columns: [Column]
    let rows: [[String]]
    let footer: Footer?
}

struct OptionsBlock: Equatable, Decodable {
    struct Item: Equatable, Decodable {
        let id: String
        let label: String
        /// Tanpa action, memilih opsi mengirim labelnya sebagai prompt.
        let action: ActionTarget?
    }

    let id: String
    let items: [Item]
}

struct MediaBlock: Equatable, Decodable {
    let imageUrl: URL?
    let caption: String
    let action: ActionTarget?
}

/// Tombol di jawaban: label, gaya Figma, dan apa yang terjadi saat diketuk.
struct ActionItem: Equatable, Decodable {
    enum Style: String, Decodable {
        case chip, suggestion, link, filled
    }

    let label: String
    let style: Style?
    let action: ActionTarget
}

/// `prompt` mengirim teks ke chat, `intent` langsung inquiry, `link` dibuka host.
struct ActionTarget: Equatable, Decodable {
    enum Kind: String, Decodable {
        case prompt, intent, link
    }

    let type: Kind
    let value: String
    let parameters: [String: String]?
}
