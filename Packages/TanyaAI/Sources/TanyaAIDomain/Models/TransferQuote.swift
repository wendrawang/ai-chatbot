//
//  TransferQuote.swift
//  TanyaAIDomain
//
//  Created by Wendra on 16/10/26.
//

import Foundation

public struct TransferQuote: Equatable, Sendable
{
    public let id: String
    public let inquiry: TransferInquiry
    public let originalFee: Money
    public let effectiveFee: Money
    public let benefitRemaining: Int?
    public let benefitTotal: Int?
    public let date: Date
    public let amount: Money
    public let total: Money
    public init(
        id: String, inquiry: TransferInquiry, originalFee: Money, effectiveFee: Money,
        benefitRemaining: Int?, benefitTotal: Int?, date: Date, amount: Money)
    {
        self.id = id
        self.inquiry = inquiry
        self.originalFee = originalFee
        self.effectiveFee = effectiveFee
        self.benefitRemaining = benefitRemaining
        self.benefitTotal = benefitTotal
        self.date = date
        self.amount = amount
        total = Money(amount: amount.amount + effectiveFee.amount, currency: amount.currency)
    }
}

public struct AuthorizationRequest: Sendable
{
    public let flowID: String
    public let quoteID: String
    public init(flowID: String, quoteID: String)
    {
        self.flowID = flowID
        self.quoteID = quoteID
    }
}

public struct AuthorizationGrant: Sendable
{
    public let id: String
    public init(id: String)
    {
        self.id = id
    }
}

public struct TransferCommand: Sendable
{
    public let id: String
    public let quote: TransferQuote
    public let authorization: AuthorizationGrant
    public init(id: String, quote: TransferQuote, authorization: AuthorizationGrant)
    {
        self.id = id
        self.quote = quote
        self.authorization = authorization
    }
}

public struct TransferReceipt: Equatable, Sendable
{
    public let commandID: String
    public let quote: TransferQuote
    public let reference: String
    public let completedAt: Date
    public init(commandID: String, quote: TransferQuote, reference: String, completedAt: Date)
    {
        self.commandID = commandID
        self.quote = quote
        self.reference = reference
        self.completedAt = completedAt
    }
}

public enum TransferSubmission: Sendable
{
    case succeeded(TransferReceipt)
    case pending
}
