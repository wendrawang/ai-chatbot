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
    func groupedByDay(calendar: Calendar = .current) -> [ChatDay] {
        var days: [ChatDay] = []
        for message in self {
            let date = message.createdAt.map(calendar.startOfDay(for:))
            if let last = days.last, date == nil || date == last.date {
                days[days.index(before: days.endIndex)] = ChatDay(date: last.date, messages: last.messages + [message])
            } else {
                days.append(ChatDay(date: date, messages: [message]))
            }
        }
        return days
    }
}
