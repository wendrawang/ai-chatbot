//
//  WireMessageKey.swift
//  TanyaAI
//
//  Created by Wendra on 12/11/26.
//

/// Key objek `Message` gateway yang dibaca `WireMessage`; decoder `.wire` sudah mengubahnya ke camelCase.
enum WireMessageKey: CodingKey {
    case messageId
    case seq
    case direction
    case payload
    case status
    case createdAt
    case clientMsgId
    case followUpQuestions
    case intent
}
