//
//  FakeChatService.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import Foundation
import XCTest

@testable import TanyaAI

/// Service palsu: memutar event SSE yang disiapkan dan mencatat inquiry.
/// Hanya untuk test yang berjalan di main actor; state mutable tidak dibagi lintas thread.
final class FakeChatService: TanyaAIService, @unchecked Sendable {
    var events: [TanyaAIServerEvent] = []
    var inquiryResponse = Data()
    /// Stream tetap terbuka (meniru jawaban panjang) sampai dibatalkan.
    var isHoldingStream = false
    private(set) var requests: [TanyaAIChatRequest] = []
    private(set) var inquiries: [TanyaAIIntent] = []

    func streamChat(_ request: TanyaAIChatRequest) -> AsyncThrowingStream<TanyaAIServerEvent, Error> {
        requests.append(request)
        let events = events
        let isHolding = isHoldingStream
        return AsyncThrowingStream { continuation in
            events.forEach { continuation.yield($0) }
            if !isHolding { continuation.finish() }
        }
    }

    func inquire(_ intent: TanyaAIIntent) async throws -> Data {
        inquiries.append(intent)
        return inquiryResponse
    }

    static func event(_ name: String, _ json: String) -> TanyaAIServerEvent {
        TanyaAIServerEvent(name: name, data: Data(json.utf8))
    }
}

@MainActor
func waitUntil(timeout: TimeInterval = 2, _ condition: () -> Bool) async {
    let deadline = Date().addingTimeInterval(timeout)
    while !condition(), Date() < deadline { await Task.yield() }
    XCTAssertTrue(condition(), "Kondisi tidak terpenuhi sebelum batas waktu")
}
