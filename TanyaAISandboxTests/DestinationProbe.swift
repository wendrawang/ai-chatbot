//
//  DestinationProbe.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 20/10/26.
//

import Foundation

/// Tujuan navigasi yang dikendalikan test. Class karena dipakai sebagai `ObservableObject`.
final class DestinationProbe: ObservableObject {
    @Published
    var destination: String?
    @Published
    var tick = 0
}
