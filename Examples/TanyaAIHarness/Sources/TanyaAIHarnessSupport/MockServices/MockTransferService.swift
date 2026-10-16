//
//  MockTransferService.swift
//  TanyaAIHarnessSupport
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import TanyaAIDomain

public actor MockTransferService: TransferServicing
{
    private let configuration: DemoConfiguration
    public private(set) var inquiryCount: Int
    public private(set) var submitCount: Int
    public private(set) var statusCount: Int
    private var receipts: [String: TransferReceipt]
    public init(configuration: DemoConfiguration)
    {
        self.configuration = configuration
        inquiryCount = 0
        submitCount = 0
        statusCount = 0
        receipts = [:]
    }

    public func inquiry(_ request: TransferInquiry) async throws -> TransferQuote
    {
        inquiryCount += 1
        let attempt = inquiryCount
        try await Task.sleep(nanoseconds: configuration.delay)
        guard configuration.scenario != .inquiryFailure || attempt > 1
        else
        {
            throw TransferServiceError.inquiryFailed
        }

        guard let amount = request.draft.amount
        else
        {
            throw TransferServiceError.inquiryFailed
        }

        return TransferQuote(
            id: request.flowID + "-quote-" + String(request.revision),
            inquiry: request,
            originalFee: Money(amount: 2500, currency: "IDR"),
            effectiveFee: Money(
                amount: 0,
                currency: "IDR"),
            benefitRemaining: 141,
            benefitTotal: 150,
            date: configuration.date,
            amount: Money(
                amount: amount,
                currency: "IDR"))
    }

    public func submit(_ command: TransferCommand) async throws -> TransferSubmission
    {
        guard let saved = receipts[command.id]
        else
        {
            submitCount += 1
            try await Task.sleep(nanoseconds: configuration.delay)
            let receipt = TransferReceipt(
                commandID: command.id,
                quote: command.quote,
                reference: "DEMO-" + command.quote.id,
                completedAt: configuration.date)
            receipts[command.id] = receipt
            return configuration.scenario == .pending ? .pending : .succeeded(receipt)
        }

        return .succeeded(saved)
    }

    public func status(commandID: String, quote: TransferQuote) async throws -> TransferSubmission
    {
        statusCount += 1
        try await Task.sleep(nanoseconds: configuration.delay)
        guard let receipt = receipts[commandID], receipt.quote == quote
        else
        {
            return .pending
        }

        return .succeeded(receipt)
    }
}
