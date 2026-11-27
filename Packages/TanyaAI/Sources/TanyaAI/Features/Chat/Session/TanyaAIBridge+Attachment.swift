//
//  TanyaAIBridge+Attachment.swift
//  TanyaAI
//
//  Created by Wendra on 27/11/26.
//

import Foundation

extension TanyaAIBridge {
    /// Lampiran pilihan nasabah selama dilayani agen. Kartu langsung tampil sebagai "sedang dikirim", lalu terkirim
    /// setelah ack tanpa menunggu salinan stream; gagal = kartu gagal yang bisa dikirim ulang. Tidak memakai turn
    /// lock karena selama dilayani agen tidak ada `turn_end`.
    /// Nil = ditolak (belum tersambung) dan salinan file langsung dibuang. Task selesai setelah respons diproses.
    /// Salinannya dipindah ke `attachmentFolder`, jadi ikut terhapus saat halaman ditutup.
    @discardableResult
    func sendAttachment(_ picked: ChatAttachmentFile) -> Task<Void, Never>? {
        guard isReady, let conversationID else {
            FileManager.default.discardChatAttachment(at: picked.url)
            return nil
        }
        let file = ChatAttachmentFile(url: FileManager.default.adoptChatAttachment(picked.url, into: attachmentFolder))
        let clientMessageID = UUID().uuidString
        localQuestions.append(LocalQuestion(id: clientMessageID, attachment: file, afterSeq: messages.latestSeq))
        latestSentQuestionID = clientMessageID
        return Task {
            await deliverAttachment(file, clientMessageID: clientMessageID, conversationID: conversationID)
        }
    }

    /// "Coba lagi" pada kartu gagal: file dan `client_msg_id` yang sama, jadi posisi kartu tetap dan gateway bisa
    /// mengenali kiriman ganda. Nil = bukan kartu gagal atau belum tersambung.
    @discardableResult
    func retryAttachment(_ clientMessageID: String) -> Task<Void, Never>? {
        guard isReady, let conversationID,
            let question = localQuestions.first(where: { $0.id == clientMessageID }), question.isFailed,
            let file = question.attachment
        else { return nil }
        updateQuestion(clientMessageID) { $0.isFailed = false }
        return Task {
            await deliverAttachment(file, clientMessageID: clientMessageID, conversationID: conversationID)
        }
    }

    /// Salinan lampiran yang tidak tampil lagi (mis. percakapan berganti) dibuang dari folder sementara.
    /// TODO: Saat pesan lampiran dari stream sudah punya tampilan, salinan perlu dipetakan ke pesan itu supaya
    /// "Lihat Detail" tetap membuka file lokal tanpa mengunduh.
    func discardRemovedAttachments(previous: [LocalQuestion]) {
        let kept = Set(localQuestions.compactMap(\.attachment?.url))
        previous.compactMap(\.attachment?.url)
            .filter { !kept.contains($0) }
            .forEach(FileManager.default.discardChatAttachment(at:))
    }
}

// MARK: - Delivery

private extension TanyaAIBridge {
    func deliverAttachment(_ file: ChatAttachmentFile, clientMessageID: String, conversationID: String) async {
        do {
            let attachment = try await file.encodedForUpload()
            let data = try await transport.sendAttachment(
                conversationID: conversationID,
                clientMessageID: clientMessageID,
                attachment: attachment
            )
            let ack = try? JSONDecoder.wire.decode(WireEnvelope<WireSendAck>.self, from: data).data
            updateQuestion(clientMessageID) { question in
                question.seq = ack.flatMap { Int($0.seq) }
                question.isSent = true
            }
            removeDeliveredQuestions()
        } catch {
            updateQuestion(clientMessageID) { $0.isFailed = true }
            didFailRequest(error, conversationID: conversationID)
        }
    }
}
