//
//  MessageListItem.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

/// Identitas baris di snapshot diffable; isi baris dicari dari id.
enum MessageListItem: Hashable {
    case welcome
    case message(String)
    case replying
}
