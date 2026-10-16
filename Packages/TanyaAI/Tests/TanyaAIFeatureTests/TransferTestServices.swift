//
//  TransferTestServices.swift
//  TanyaAIFeatureTests
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import TanyaAIDomain

actor TransferTestService: TransferServicing
{
    var inquiries = 0
    var submits = 0
    var checks = 0
    var isFailingInquiry = false
    var isPending = false
    var continuation: CheckedContinuation<TransferQuote, Error>?
    var isDelayed = false
    func setDelayed()
    {
        isDelayed = true
    }

    func setFailing()
    {
        isFailingInquiry = true
    }

    func setPending()
    {
        isPending = true
    }

    func inquiry(_ request: TransferInquiry) async throws -> TransferQuote
    {
        inquiries += 1
        guard !isFailingInquiry
        else
        {
            isFailingInquiry = false
            throw TransferServiceError.inquiryFailed
        }

        guard !isDelayed
        else
        {
            return try await withCheckedThrowingContinuation
            {
                continuation = $0
            }
        }

        return Self.quote(request)
    }

    func release(_ request: TransferInquiry)
    {
        continuation?.resume(returning: Self.quote(request))
        continuation = nil
    }

    func submit(_ command: TransferCommand) async throws -> TransferSubmission
    {
        submits += 1
        return isPending ? .pending : .succeeded(Self.receipt(command.id, quote: command.quote))
    }

    func status(commandID: String, quote: TransferQuote) async throws -> TransferSubmission
    {
        checks += 1
        return .succeeded(Self.receipt(commandID, quote: quote))
    }

    static func quote(_ request: TransferInquiry) -> TransferQuote
    {
        TransferQuote(
            id: "test-quote",
            inquiry: request,
            originalFee: Money(amount: 2500, currency: "IDR"),
            effectiveFee: Money(amount: 0, currency: "IDR"),
            benefitRemaining: 141,
            benefitTotal: 150,
            date: Date(timeIntervalSince1970: 1000),
            amount: Money(
                amount: request.draft.amount ?? 0,
                currency: "IDR"))
    }

    static func receipt(_ id: String, quote: TransferQuote) -> TransferReceipt
    {
        TransferReceipt(commandID: id, quote: quote, reference: "DEMO-test", completedAt: quote.date)
    }
}

actor AuthorizerTestService: TransactionAuthorizing
{
    var count = 0
    var isRejecting = false
    func rejectOnce()
    {
        isRejecting = true
    }

    func authorize(_: AuthorizationRequest) async throws -> AuthorizationGrant
    {
        count += 1
        guard !isRejecting
        else
        {
            isRejecting = false
            throw TransferServiceError.authorizationRejected
        }

        return AuthorizationGrant(id: "demo-grant")
    }
}
