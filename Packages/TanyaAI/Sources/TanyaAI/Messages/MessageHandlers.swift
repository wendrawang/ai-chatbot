//
//  MessageHandlers.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

/// Aksi dari baris ke view model; closure agar baris tetap value type yang ringan.
struct MessageHandlers {
    /// Kirim teks shortcut sebagai chat.
    let shortcut: (String) -> Void
    let loadOlder: () -> Void
}
