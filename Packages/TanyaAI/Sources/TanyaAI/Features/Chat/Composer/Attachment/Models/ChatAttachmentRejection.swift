//
//  ChatAttachmentRejection.swift
//  TanyaAI
//
//  Created by Wendra on 26/11/26.
//

/// Alasan lampiran ditolak sebelum dipakai; tampil sebagai snackbar di halaman chat (keputusan user).
enum ChatAttachmentRejection: Error, Equatable {
    /// Foto galeri selain HEIC, JPG/JPEG, atau PNG. Galeri sistem tidak bisa memfilter per format.
    case unsupportedFormat
    /// File lebih besar dari `FileManager.chatAttachmentByteLimit`.
    case tooLarge

    var message: ChatCopy {
        switch self {
        case .unsupportedFormat: return .attachmentUnsupportedFormat
        case .tooLarge: return .attachmentTooLarge
        }
    }
}
