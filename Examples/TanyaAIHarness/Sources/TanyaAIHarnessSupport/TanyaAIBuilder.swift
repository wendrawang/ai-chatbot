//
//  TanyaAIBuilder.swift
//  TanyaAIHarnessSupport
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import TanyaAIDomain
import TanyaAIFeature

@MainActor
public enum TanyaAIBuilder
{
    public static func makeSession(
        scenario: TransferScenario,
        identity: SessionIdentity,
        language: String,
        history: ConversationHistoryStoring,
        onLink: @escaping (URL) -> Void,
        onClose: @escaping () -> Void) throws -> TanyaAISession
    {
        let configuration = DemoConfiguration(scenario: scenario)
        let dependencies = TanyaAIDependencies(
            conversation: MockConversationService(configuration: configuration),
            transfers: MockTransferService(configuration: configuration),
            authorizer: MockTransactionAuthorizer(configuration: configuration),
            history: history,
            now:
            {
                configuration.date
            },

            makeMessageID:
            {
                UUID().uuidString
            })
        return try TanyaAISession(
            context: SessionContext(identity: identity, language: language),
            dependencies: dependencies,
            configuration: configuration.transfer,
            onLink: onLink,
            onClose: onClose)
    }
}
