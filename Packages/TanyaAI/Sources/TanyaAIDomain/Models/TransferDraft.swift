//
//  TransferDraft.swift
//  TanyaAIDomain
//
//  Created by Wendra on 16/10/26.
//

import Foundation

public struct TransferIntent: Equatable, Sendable
{
    public let eventID: String
    public let flowID: String
    public let messageID: String
    public let sessionID: String
    public let recipient: Account
    public init(eventID: String, flowID: String, messageID: String, sessionID: String, recipient: Account)
    {
        self.eventID = eventID
        self.flowID = flowID
        self.messageID = messageID
        self.sessionID = sessionID
        self.recipient = recipient
    }
}

public struct TransferDraft: Equatable, Sendable
{
    public var amount: Decimal?
    public var source: Account
    public let recipient: Account
    public var method: String
    public var purpose: String
    public var note: String
    public init(amount: Decimal?, source: Account, recipient: Account, method: String, purpose: String, note: String)
    {
        self.amount = amount
        self.source = source
        self.recipient = recipient
        self.method = method
        self.purpose = purpose
        self.note = note
    }
}

public struct TransferInquiry: Equatable, Sendable
{
    public let flowID: String
    public let sessionID: String
    public let revision: Int
    public let draft: TransferDraft
    public init(flowID: String, sessionID: String, revision: Int, draft: TransferDraft)
    {
        self.flowID = flowID
        self.sessionID = sessionID
        self.revision = revision
        self.draft = draft
    }
}
