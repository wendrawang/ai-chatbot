//
//  ChatWelcome.swift
//  TanyaAI
//
//  Created by Wendra on 26/10/26.
//

/// Isi percakapan kosong dari config BE: greeting dan shortcut yang dikirim sebagai chat.
struct ChatWelcome: Equatable {
    let greeting: String
    let shortcuts: [ChatShortcut]
}

extension ChatWelcome {
    init(_ payload: ConfigPayload) {
        greeting = payload.greeting
        shortcuts = (payload.shortcuts ?? []).map { shortcut in
            let message = shortcut.message.flatMap { $0.isEmpty ? nil : $0 } ?? shortcut.label
            return ChatShortcut(id: shortcut.id, label: shortcut.label, message: message)
        }
    }
}
