//
//  ChatWireEvent.swift
//  TanyaAI
//
//  Created by Wendra on 12/11/26.
//

/// Nama event SSE pada contract chat-gateway. Metadata teknis, bukan copy untuk pengguna.
enum ChatWireEvent {
    /// Nama default event SSE bila baris `event:` tidak ada.
    static let message = "message"
    static let turnEnd = "turn_end"
    /// Perpindahan state percakapan, mis. masuk antrean agen.
    static let state = "state"
    /// Notifikasi untuk nasabah, mis. agen bergabung atau antrean habis.
    static let system = "system"
    /// Ephemeral (tanpa baris outbox): `id:`-nya bukan posisi replay.
    static let typing = "typing"
}
