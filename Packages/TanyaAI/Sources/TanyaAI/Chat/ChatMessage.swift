//
//  ChatMessage.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import Foundation

/// Satu baris percakapan. Value type agar daftar hanya me-render ulang baris yang berubah.
struct ChatMessage: Identifiable, Equatable {
    enum Role: Equatable {
        case user, assistant
    }

    let id: String
    let role: Role
    let createdAt: Date
    /// Tampilkan tanggal di atas pesan ini (pesan pertama pada hari itu).
    let isDateVisible: Bool
    /// Teks pengguna, atau teks jawaban bermarkup yang tumbuh saat streaming.
    var text = String()
    /// Teks loading selama menunggu; nil setelah jawaban mulai tampil.
    var status: String?
    var blocks: [ChatBlock] = []
    /// Opsi terpilih per indeks blok `options`; terpilih berarti read-only.
    var selections: [Int: String] = [:]
    /// Hanya jawaban terakhir yang action/pilihannya aktif; link tetap bisa dibuka.
    var isInteractive = true
}
