//
//  Services.swift
//  TanyaAIDomain
//
//  Created by Wendra on 16/10/26.
//

import Foundation

public protocol ConversationServicing
{
    func open(context: SessionContext) async throws -> AsyncThrowingStream<ConversationEvent, Error>
    func send(_ request: ConversationRequest) async throws
    func close() async
}

public protocol TransferServicing
{
    func inquiry(_ request: TransferInquiry) async throws -> TransferQuote
    func submit(_ command: TransferCommand) async throws -> TransferSubmission
    func status(commandID: String, quote: TransferQuote) async throws -> TransferSubmission
}

public protocol TransactionAuthorizing
{
    /// Demo authorizes a completed UI challenge; digits are never passed into domain/history models.
    func authorize(_ request: AuthorizationRequest) async throws -> AuthorizationGrant
}

public protocol ConversationHistoryStoring
{
    func load(identity: SessionIdentity) async -> ConversationSnapshot?
    func save(_ snapshot: ConversationSnapshot) async
}
