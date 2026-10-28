//
//  ChatElementIdentifier.swift
//  TanyaAI
//
//  Created by Wendra on 17/10/26.
//

/// Technical identifiers are separate from localized user-facing strings.
enum ChatElementIdentifier {
    static let more = "chat.more"
    static let welcome = "chat.welcome"

    /// Kartu shortcut ke-`index` (mulai 0) sesuai urutan dari BE.
    static func shortcut(_ index: Int) -> String { "welcome.shortcut.\(index)" }
}
