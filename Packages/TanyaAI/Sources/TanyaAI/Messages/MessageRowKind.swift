//
//  MessageRowKind.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

/// Isi satu baris daftar.
enum MessageRowKind: Equatable {
    case welcome(ChatWelcome, isEnabled: Bool)
    case message(ChatMessage)
    case replying
}
