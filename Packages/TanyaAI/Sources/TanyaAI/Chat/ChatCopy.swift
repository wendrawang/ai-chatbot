//
//  ChatCopy.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

import DesignKit
import Foundation

/// Key copy Tanya AI di `Resources/*.lproj/Localizable.strings`. Satu-satunya tempat key ditulis;
/// `LocalizationTests` memastikan setiap case ada di en/id/zh-Hans dan tidak ada key yang yatim.
enum ChatCopy: String, CaseIterable {
    case placeholder = "chat.placeholder"
    case send = "chat.send"
    case more = "chat.more"
    case newConversation = "chat.newConversation"
    case title = "chat.title"
    case back = "chat.back"
}

extension String {
    /// Copy Tanya AI dari bundle package sesuai locale host.
    init(_ copy: ChatCopy, locale: Locale) {
        self.init(key: copy.rawValue, bundle: .module, locale: locale)
    }
}
