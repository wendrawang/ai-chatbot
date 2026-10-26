//
//  ChatTurn.swift
//  TanyaAI
//
//  Created by Wendra on 26/10/26.
//

import DesignKit

/// Giliran tanya-jawab; satu pertanyaan per waktu.
enum ChatTurn: Equatable {
    case idle
    /// `send` berjalan atau sudah diterima BE; menunggu pesan user muncul di stream.
    case sending
    /// Pesan user `questionId` sudah tampil; menunggu jawaban.
    case waiting(questionId: String)
    /// Permintaan stop untuk `questionId` sedang dikirim.
    case stopping(questionId: String)

    var isReplying: Bool {
        switch self {
        case .waiting, .stopping: return true
        case .idle, .sending: return false
        }
    }

    var composerAction: ComposerAction {
        switch self {
        case .idle: return .send
        case .sending: return .sending
        case .waiting, .stopping: return .stop
        }
    }
}

/// Pesan singkat di atas composer saat aksi gagal; hilang pada aksi berikutnya.
enum ChatNotice: Equatable {
    case sendFailed, stopFailed
}
