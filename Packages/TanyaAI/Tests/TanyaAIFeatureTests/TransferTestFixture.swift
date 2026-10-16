//
//  TransferTestFixture.swift
//  TanyaAIFeatureTests
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import TanyaAIDomain
@testable import TanyaAIFeature

@MainActor
struct TransferTestFixture
{
    let model: TransferFlowViewModel
    let service: TransferTestService
    let authorizer: AuthorizerTestService
    let draft: TransferDraft
    init()
    {
        let source = Account(
            id: "source",
            name: "SENDER DEMO",
            bank: "BANK DEMO",
            maskedNumber: "•••• 0001",
            balance: nil)
        let recipient = Account(
            id: "recipient",
            name: "RECEIVER DEMO",
            bank: "BANK DEMO",
            maskedNumber: "•••• 0002",
            balance: nil)
        draft = TransferDraft(
            amount: 10000,
            source: source,
            recipient: recipient,
            method: "BI FAST",
            purpose: "fundTransfer",
            note: "")
        let intent = TransferIntent(
            eventID: "event",
            flowID: "flow",
            messageID: "message",
            sessionID: "session",
            recipient: recipient)
        let config = TransferConfiguration(
            pinLength: 6,
            noteLimit: 25,
            minimumAmount: 1,
            maximumAmount: 25_000_000,
            initialAmount: 10000,
            methods: ["BI FAST"],
            purposes: ["fundTransfer"],
            sourceAccounts: [source],
            brandName: "BANK DEMO")
        service = TransferTestService()
        authorizer = AuthorizerTestService()
        model = TransferFlowViewModel(
            snapshot: TransferSnapshot(
                intent: intent,
                revision: 0,
                phase: .editing(draft, nil)),
            service: service,
            authorizer: authorizer,
            configuration: config)
    }

    func settle() async
    {
        await model.operation?.value
    }
}
