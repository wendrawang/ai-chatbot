//
//  Array+ChatMessage.swift
//  TanyaAI
//
//  Created by Wendra on 28/10/26.
//

import Foundation

extension Array where Element == ChatMessage {
    /// `seq` terbesar di daftar; dikirim sebagai `Last-Event-ID` dan batas mengejar history.
    var latestSeq: Int? {
        map(\.seq).max()
    }

    /// Gabung tanpa menumpuk: pesan dengan `id` sama diganti versi yang datang (mis. tombstone `canceled`),
    /// pesan baru ditambahkan, hasil urut `seq` naik walau history datang terbaru dulu.
    func merging(_ incoming: [ChatMessage]) -> [ChatMessage] {
        // Jalur cepat SSE: satu pesan baru di ujung, tanpa mengurutkan ulang seluruh daftar.
        if let message = incoming.first, incoming.dropFirst().isEmpty, message.seq > (latestSeq ?? .min),
            !contains(where: { $0.id == message.id })
        {
            return self + incoming
        }
        var byID = Dictionary(map { ($0.id, $0) }, uniquingKeysWith: { _, latest in latest })
        incoming.forEach { byID[$0.id] = $0 }
        return byID.values.sorted { $0.seq < $1.seq }
    }

    /// Kelompok per hari kalender untuk chip tanggal; urutan tetap kronologis. Pesan tanpa `created_at`
    /// ikut hari pesan sebelumnya.
    /// O(n): pesan di-append ke buffer hari berjalan, kelompok dibentuk sekali saat hari berganti.
    func groupedByDay(calendar: Calendar = .current) -> [ChatDay] {
        var days: [ChatDay] = []
        var current: [ChatMessage] = []
        var currentDate: Date?
        for message in self {
            let date = message.createdAt.map(calendar.startOfDay(for:))
            if !current.isEmpty, let date, date != currentDate {
                days.append(ChatDay(date: currentDate, messages: current))
                current.removeAll(keepingCapacity: true)
            }
            if current.isEmpty {
                currentDate = date
            }
            current.append(message)
        }
        if !current.isEmpty {
            days.append(ChatDay(date: currentDate, messages: current))
        }
        return days
    }
}
