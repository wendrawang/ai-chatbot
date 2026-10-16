//
//  ChatState.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import TanyaAIDomain

struct ChatState
{
    var messages: [ChatMessage]
    var language: String
    var promptAnchor: String?
    var latestRequest: Int
    init(language: String)
    {
        messages = []
        self.language = language
        promptAnchor = nil
        latestRequest = 0
    }
}
