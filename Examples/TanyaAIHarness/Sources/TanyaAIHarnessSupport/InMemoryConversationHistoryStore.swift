//
//  InMemoryConversationHistoryStore.swift
//  TanyaAIHarnessSupport
//
//  Created by Wendra on 16/10/26.
//

import TanyaAIDomain

public actor InMemoryConversationHistoryStore: ConversationHistoryStoring
{
    private var snapshots: [SessionIdentity: ConversationSnapshot]
    public init()
    {
        snapshots = [:]
    }

    public func load(identity: SessionIdentity) async -> ConversationSnapshot?
    {
        snapshots[identity]
    }

    public func save(_ snapshot: ConversationSnapshot) async
    {
        guard snapshot.revision >= (snapshots[snapshot.identity]?.revision ?? 0)
        else
        {
            return
        }

        snapshots[snapshot.identity] = snapshot
    }
}
