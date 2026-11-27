//
//  LocalQuestion.swift
//  TanyaAI
//
//  Created by Wendra on 2/11/26.
//

import Foundation

/// Kiriman nasabah yang langsung tampil saat dikirim, sebelum salinannya datang dari stream: pertanyaan teks atau
/// lampiran. Salinan stream (dicocokkan lewat `client_msg_id` atau seq ack) menggantikannya. Teks yang gagal tetap
/// tampil abu-abu tanpa retry selama halaman hidup, karena gateway tidak pernah menyimpannya; lampiran yang gagal
/// bisa dikirim ulang dengan id yang sama.
struct LocalQuestion: Identifiable, Equatable {
    /// `client_msg_id` yang dikirim ke gateway.
    let id: String
    let content: LocalQuestionContent
    /// `seq` pesan terakhir saat dikirim; posisi bubble di daftar tetap setelah pesan itu.
    let afterSeq: Int?
    /// Waktu perangkat saat dikirim; menentukan chip tanggal selama salinan dari stream belum datang.
    var sentAt: Date
    /// Seq dari ack kirim; nil sebelum ack atau bila gateway menolak.
    var seq: Int?
    var isFailed: Bool
    /// True setelah ack kirim diterima. Kartu lampiran tampil terkirim sejak ack, tanpa menunggu salinan stream.
    var isSent = false

    init(id: String, text: String, afterSeq: Int?, sentAt: Date = Date(), isFailed: Bool = false) {
        self.id = id
        content = .text(text)
        self.afterSeq = afterSeq
        self.sentAt = sentAt
        self.isFailed = isFailed
    }

    init(id: String, attachment: ChatAttachmentFile, afterSeq: Int?) {
        self.id = id
        content = .attachment(attachment)
        self.afterSeq = afterSeq
        sentAt = Date()
        isFailed = false
    }

    /// Nil untuk lampiran.
    var text: String? {
        guard case .text(let text) = content else { return nil }
        return text
    }

    /// Nil untuk pertanyaan teks.
    var attachment: ChatAttachmentFile? {
        guard case .attachment(let file) = content else { return nil }
        return file
    }

    /// Lampiran sedang dikirim: sudah tampil, belum ada ack maupun error.
    var isSending: Bool { !isSent && !isFailed }

    /// Salinan pertanyaan ini dari stream atau history di `messages` (urut `seq` naik); nil selama belum datang.
    /// Salinan yang belum punya tampilan (mis. pesan lampiran sebelum ada renderernya) tidak menggantikan kiriman
    /// lokal, supaya kartu lampiran tidak hilang dari daftar.
    func copy(in messages: [ChatMessage]) -> ChatMessage? {
        let floor = afterSeq ?? .min
        return messages.reversed().prefix { $0.seq > floor }.first { message in
            message.author == .user && ChatRow.message(message).isVisible
                && (message.clientMessageID == id || (seq != nil && message.seq == seq))
        }
    }
}
