//
//  DownloadCounter.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import Foundation

/// Menghitung panggilan `fetch` palsu dari closure `@Sendable` yang berjalan di luar main actor.
actor DownloadCounter {
    private(set) var count = 0

    /// Menaikkan hitungan dan mengembalikan urutan panggilan ini (mulai 1).
    func increment() -> Int {
        count += 1
        return count
    }
}
