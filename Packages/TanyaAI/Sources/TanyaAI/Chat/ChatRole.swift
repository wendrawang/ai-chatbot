//
//  ChatRole.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

/// Pengirim pesan. Raw value sama dengan `role` di JSON kontrak.
enum ChatRole: String, Decodable {
    case user, assistant
}
