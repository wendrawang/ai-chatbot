//
//  ChatTestServices.swift
//  TanyaAIFeatureTests
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import TanyaAIDomain

actor ChatTestService: ConversationServicing
{
    var isClosed = false
    func open(context _: SessionContext) async throws -> AsyncThrowingStream<ConversationEvent, Error>
    {
        AsyncThrowingStream
        {
            _ in
        }
    }

    func send(_: ConversationRequest) async throws
    {
    }

    func close() async
    {
        isClosed = true
    }
}

actor HistoryTestStore: ConversationHistoryStoring
{
    var snapshots: [SessionIdentity: ConversationSnapshot] = [:]
    func load(identity: SessionIdentity) async -> ConversationSnapshot?
    {
        snapshots[identity]
    }

    func save(_ snapshot: ConversationSnapshot) async
    {
        guard snapshot.revision >= (snapshots[snapshot.identity]?.revision ?? 0)
        else
        {
            return
        }

        snapshots[snapshot.identity] = snapshot
    }
}
