//
//  DemoConfiguration.swift
//  TanyaAIHarnessSupport
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import TanyaAIDomain

public enum TransferScenario: String, CaseIterable, Identifiable, Sendable
{
    case success, inquiryFailure, pinRejection, pending, duplicateIntent, lateInquiry
    public var id: String
    {
        rawValue
    }
}

public struct DemoConfiguration: Sendable
{
    public let scenario: TransferScenario
    public let transfer: TransferConfiguration
    public let recipient: Account
    public let date: Date
    public let delay: UInt64
    public init(scenario: TransferScenario)
    {
        self.scenario = scenario
        let source = Account(
            id: "source-demo",
            name: "PENGIRIM DEMO",
            bank: "BANK DEMO",
            maskedNumber: "•••• 0001",
            balance: Money(amount: 1_000_000, currency: "IDR"))
        let other = Account(
            id: "source-demo-other",
            name: "PENGIRIM DEMO",
            bank: "BANK DEMO",
            maskedNumber: "•••• 0002",
            balance: Money(amount: 2_000_000, currency: "IDR"))
        recipient = Account(
            id: "recipient-demo",
            name: "PENERIMA DEMO",
            bank: "BANK DEMO",
            maskedNumber: "•••• 0099",
            balance: nil)
        transfer = TransferConfiguration(
            pinLength: 6,
            noteLimit: 25,
            minimumAmount: 1,
            maximumAmount: 25_000_000,
            initialAmount: 10000,
            methods: ["BI FAST"],
            purposes: ["fundTransfer"],
            sourceAccounts: [source, other],
            brandName: "BANK DEMO")
        date = Date(timeIntervalSince1970: 1_792_126_800)
        delay = scenario == .lateInquiry ? 3_000_000_000 : 150_000_000
    }
}
