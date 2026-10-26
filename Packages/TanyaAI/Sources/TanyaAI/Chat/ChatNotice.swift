//
//  ChatNotice.swift
//  TanyaAI
//
//  Created by Wendra on 26/10/26.
//

/// Pesan singkat di atas composer saat aksi gagal; hilang pada aksi berikutnya.
enum ChatNotice: Equatable {
    case sendFailed, stopFailed
}
