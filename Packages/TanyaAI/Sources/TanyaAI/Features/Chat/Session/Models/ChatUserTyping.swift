//
//  ChatUserTyping.swift
//  TanyaAI
//
//  Created by Wendra on 12/11/26.
//

/// Status sinyal "nasabah sedang mengetik" yang diteruskan ke agen (contract §7.7). Hanya nilainya; jeda dan
/// pengiriman tetap milik `TanyaAIBridge`. `typing:true` dikirim saat mulai mengetik dan paling cepat diulang setelah
/// jeda refresh; `typing:false` hanya dikirim bila `true` pernah dikirim. Sinyal yang menunggu selama kiriman
/// sebelumnya berjalan digabung menjadi yang terbaru.
struct ChatUserTyping: Equatable {
    /// Agen sedang diberi tahu nasabah mengetik: `typing:true` terakhir belum disusul `false`.
    private(set) var isAnnounced = false
    /// `typing:true` diminta kurang dari jeda refresh yang lalu, jadi ketikan berikutnya tidak dikirim lagi.
    private(set) var isFresh = false
    /// Ada sinyal yang belum dikirim; nilainya selalu `isAnnounced` saat itu.
    private var isPending = false
    /// Nilai terakhir yang benar-benar dikirim ke server; `false` tanpa `true` sebelumnya tidak perlu dikirim.
    private var isDelivered = false

    /// Ketikan baru. True bila `typing:true` perlu dikirim sekarang.
    mutating func begin() -> Bool {
        guard !isFresh else { return false }
        isAnnounced = true
        isFresh = true
        isPending = true
        return true
    }

    /// Jeda refresh lewat: ketikan berikutnya mengirim `typing:true` lagi supaya tidak kedaluwarsa di server.
    mutating func expireFreshness() {
        isFresh = false
    }

    /// Berhenti mengetik. True bila `typing:false` perlu dikirim, yaitu bila `true` pernah diminta.
    mutating func end() -> Bool {
        isFresh = false
        guard isAnnounced else { return false }
        isAnnounced = false
        isPending = true
        return true
    }

    /// Sinyal berikutnya untuk dikirim, diambil tepat sebelum kirim. Nil bila tidak ada yang menunggu, bila
    /// `isDeliverable` false (tidak lagi dengan agen atau sesi berakhir), atau bila `false` tanpa `true` sebelumnya.
    mutating func takePending(isDeliverable: Bool) -> Bool? {
        guard isPending else { return nil }
        isPending = false
        guard isDeliverable, isAnnounced || isDelivered else { return nil }
        isDelivered = isAnnounced
        return isAnnounced
    }

    /// Agen selesai, percakapan berganti, atau sesi berakhir: tidak ada lagi yang menerima sinyal.
    mutating func reset() {
        self = ChatUserTyping()
    }
}
