//
//  TanyaAIDependencies.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import TanyaAIDomain

public struct TanyaAIDependencies
{
    let conversation: ConversationServicing
    let transfers: TransferServicing
    let authorizer: TransactionAuthorizing
    let history: ConversationHistoryStoring
    let now: () -> Date
    let makeMessageID: () -> String
    public init(
        conversation: ConversationServicing,
        transfers: TransferServicing,
        authorizer: TransactionAuthorizing,
        history: ConversationHistoryStoring,
        now: @escaping () -> Date,
        makeMessageID: @escaping () -> String)
    {
        self.conversation = conversation
        self.transfers = transfers
        self.authorizer = authorizer
        self.history = history
        self.now = now
        self.makeMessageID = makeMessageID
    }
}
