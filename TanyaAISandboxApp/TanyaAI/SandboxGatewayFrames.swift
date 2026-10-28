//
//  SandboxGatewayFrames.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 28/10/26.
//

import Foundation

/// Body dan baris SSE berbentuk contract chat-gateway 1.0.1 untuk gateway tiruan sandbox.
/// Menyimpan `seq` percakapan; setiap frame memakai nomor berikutnya.
struct SandboxGatewayFrames {
    static let conversationID = "sandbox-conversation"
    static let connected = ": connected"
    static let initialize = Data(
        #"{"success":true,"data":{"conversation_id":"sandbox-conversation","state":"BOT_ACTIVE"}}"#.utf8
    )
    static let emptyHistory = Data(#"{"success":true,"data":{"messages":[],"next_before":null}}"#.utf8)
    static let badRequest = Data(
        #"{"success":false,"error_code":"bad_request","data":null,"retryable":false,"request_id":"sandbox"}"#.utf8
    )
    static let badRequestStatus = 400
    /// Data dummy: jawaban bot mengulang pertanyaan.
    static func reply(to question: String) -> String { "Jawaban contoh untuk: \(question)" }

    private var seq = 0

    mutating func ack() -> Data {
        Data(#"{"success":true,"data":{"message_id":"ack","seq":"\#(seq + 1)"}}"#.utf8)
    }

    mutating func message(direction: String, text: String, clientMessageID: String? = nil) -> [String] {
        seq += 1
        let message = SandboxWireMessage(
            messageId: UUID().uuidString, seq: String(seq), direction: direction, payload: text,
            clientMsgId: clientMessageID
        )
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let json = (try? encoder.encode(message)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        return ["id: \(seq)", "event: message", "data: \(json)", ""]
    }

    mutating func turnEnd() -> [String] {
        seq += 1
        return ["id: \(seq)", "event: turn_end", #"data: {"status":"completed","active_turn_id":"sandbox"}"#, ""]
    }
}
