//
//  ChatAttachmentRejectionNotice.swift
//  TanyaAI
//
//  Created by Wendra on 26/11/26.
//

import Foundation

/// Satu kejadian penolakan lampiran. Id baru di tiap kejadian, jadi alasan yang sama berturut-turut tetap memulai ulang
/// hitungan snackbar dan dibacakan lagi oleh VoiceOver.
struct ChatAttachmentRejectionNotice: Equatable {
    let id = UUID()
    let reason: ChatAttachmentRejection
}
