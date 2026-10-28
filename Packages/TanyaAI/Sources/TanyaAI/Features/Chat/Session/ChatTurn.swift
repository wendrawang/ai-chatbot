//
//  ChatTurn.swift
//  TanyaAI
//
//  Created by Wendra on 29/10/26.
//

/// Satu pertanyaan per waktu. Hanya `turn_end` dengan `seq` setelah pertanyaan yang sedang ditunggu
/// (seq dari ack kirim) yang membuka kunci, jadi `turn_end` lama hasil replay setelah reconnect tidak
/// membuka kirim untuk pertanyaan baru. `turn_end` boleh datang sebelum ack (stream lebih cepat dari
/// respons HTTP); ia dicatat lalu dicocokkan saat ack tiba.
struct ChatTurn: Equatable {
    private(set) var isAwaiting = false
    /// Seq pertanyaan dari ack; nil selama ack belum diterima.
    private var questionSeq: Int?
    /// Seq `turn_end` terbesar sejak pertanyaan dikirim.
    private var latestEndSeq: Int?

    mutating func start() {
        self = ChatTurn(isAwaiting: true)
    }

    /// Ack gateway diterima. Seq yang tidak terbaca = turn berikutnya mana pun dianggap penutupnya.
    mutating func accept(questionSeq seq: Int?) {
        guard isAwaiting else { return }
        let questionSeq = seq ?? .min
        self.questionSeq = questionSeq
        if let latestEndSeq, latestEndSeq > questionSeq {
            self = ChatTurn()
        }
    }

    /// Event `turn_end`; tanpa `id` dianggap milik turn terbaru.
    mutating func end(seq: Int?) {
        guard isAwaiting else { return }
        let seq = seq ?? .max
        latestEndSeq = max(latestEndSeq ?? seq, seq)
        if let questionSeq, seq > questionSeq {
            self = ChatTurn()
        }
    }

    /// Kirim ditolak atau percakapan berganti.
    mutating func cancel() {
        self = ChatTurn()
    }
}
