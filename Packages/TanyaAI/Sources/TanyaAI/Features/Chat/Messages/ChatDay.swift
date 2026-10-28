//
//  ChatDay.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import Foundation

/// Pesan pada satu hari kalender (zona waktu perangkat); chip tanggal tampil di atasnya.
struct ChatDay: Identifiable, Equatable {
    /// Awal hari; nil bila pesan pertama tidak punya `created_at` (tanpa chip tanggal).
    let date: Date?
    let messages: [ChatMessage]

    /// Pesan pertama hari ini; stabil walau pesan baru ditambahkan di hari yang sama.
    var id: String { messages.first?.id ?? String() }
}
