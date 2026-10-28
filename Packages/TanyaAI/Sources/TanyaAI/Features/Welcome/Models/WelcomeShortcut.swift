//
//  WelcomeShortcut.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

import Foundation

/// Satu kartu shortcut di halaman sambutan. Saat diketuk, `prompt` dikirim sebagai chat.
public struct WelcomeShortcut: Decodable, Equatable {
    public let title: String
    public let description: String
    /// Nil bila BE mengirim URL kosong/tidak valid; kartu tetap tampil dengan placeholder ikon.
    public let iconURL: URL?
    public let prompt: String

    public init(title: String, description: String, iconURL: URL?, prompt: String) {
        self.title = title
        self.description = description
        self.iconURL = iconURL
        self.prompt = prompt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: WelcomeShortcutKey.self)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        iconURL = try container.decodeIfPresent(String.self, forKey: .iconUrl).flatMap(URL.init(string:))
        prompt = try container.decode(String.self, forKey: .prompt)
    }
}
