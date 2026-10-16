//
//  MockTransactionAuthorizer.swift
//  TanyaAIHarnessSupport
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import TanyaAIDomain

public actor MockTransactionAuthorizer: TransactionAuthorizing
{
    private let configuration: DemoConfiguration
    public private(set) var count: Int
    public init(configuration: DemoConfiguration)
    {
        self.configuration = configuration
        count = 0
    }

    public func authorize(_ request: AuthorizationRequest) async throws -> AuthorizationGrant
    {
        count += 1
        let attempt = count
        try await Task.sleep(nanoseconds: configuration.delay)
        guard configuration.scenario != .pinRejection || attempt > 1
        else
        {
            throw TransferServiceError.authorizationRejected
        }

        return AuthorizationGrant(id: "DEMO-AUTH-" + request.flowID + "/" + request.quoteID)
    }
}
