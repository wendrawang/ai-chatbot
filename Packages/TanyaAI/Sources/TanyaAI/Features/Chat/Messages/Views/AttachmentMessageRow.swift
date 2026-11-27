//
//  AttachmentMessageRow.swift
//  TanyaAI
//
//  Created by Wendra on 27/11/26.
//

import DesignKit
import SwiftUI

/// Lampiran yang dikirim nasabah: kartu file rata kanan. Selama dikirim kartu tidak bisa diketuk; setelah ack
/// diketuk = buka salinan lokalnya; gagal diketuk = kirim ulang dengan `client_msg_id` yang sama.
@MainActor
struct AttachmentMessageRow: View {
    @Environment(\.locale) private var locale
    let question: LocalQuestion
    let file: ChatAttachmentFile
    let onOpen: (URL) -> Void
    let onRetry: (String) -> Void

    var body: some View {
        FileCard(name: file.name, status: status, onTap: tap)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .accessibilityIdentifier(identifier)
    }
}

// MARK: - Helpers

private extension AttachmentMessageRow {
    var status: FileCardStatus {
        if question.isFailed {
            return .failed(
                note: String(ChatCopy.attachmentFailed, locale: locale),
                action: String(ChatCopy.attachmentRetry, locale: locale)
            )
        }
        guard question.isSent else { return .sending(note: String(ChatCopy.attachmentSending, locale: locale)) }
        return .ready(note: file.formatLabel, action: String(ChatCopy.attachmentDetail, locale: locale))
    }

    var identifier: String {
        if question.isFailed { return ChatElementIdentifier.failedAttachment }
        return question.isSent ? ChatElementIdentifier.attachment : ChatElementIdentifier.sendingAttachment
    }

    func tap() {
        if question.isFailed { return onRetry(question.id) }
        onOpen(file.url)
    }
}
