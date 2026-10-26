//
//  ChatShortcut.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

/// Pilihan cepat di percakapan kosong.
struct ChatShortcut: Identifiable, Equatable {
    let id: String
    let label: String
    /// Teks yang dikirim saat shortcut ditekan.
    let message: String
}
