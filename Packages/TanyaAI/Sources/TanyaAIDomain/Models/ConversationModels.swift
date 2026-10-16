//
//  ConversationModels.swift
//  TanyaAIDomain
//
//  Created by Wendra on 16/10/26.
//

import Foundation

public enum ConversationRequest: Sendable
{
    case text(String, language: String)
    case transfer
}

public enum ConversationEvent: Sendable
{
    case answerStarted(id: String, date: Date)
    case textDelta(id: String, text: String)
    case answerFinished(id: String)
    case suggestion(id: String, date: Date)
    case intent(TransferIntent, date: Date)
}

public enum ChatMessageContent: Equatable, Sendable
{
    case user(String)
    case answer(String, isStreaming: Bool)
    case suggestion
    case transfer(TransferSnapshot)
}

public struct ChatMessage: Equatable, Identifiable, Sendable
{
    public let id: String
    public let date: Date
    public var revision: Int
    public var content: ChatMessageContent
    public init(id: String, date: Date, revision: Int, content: ChatMessageContent)
    {
        self.id = id
        self.date = date
        self.revision = revision
        self.content = content
    }
}

public struct ConversationSnapshot: Sendable
{
    public let identity: SessionIdentity
    public let revision: Int
    public let messages: [ChatMessage]
    public init(identity: SessionIdentity, revision: Int, messages: [ChatMessage])
    {
        self.identity = identity
        self.revision = revision
        self.messages = messages
    }
}
