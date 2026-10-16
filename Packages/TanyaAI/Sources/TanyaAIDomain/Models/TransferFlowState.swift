//
//  TransferFlowState.swift
//  TanyaAIDomain
//
//  Created by Wendra on 16/10/26.
//

import Foundation

public enum TransferFieldError: Sendable
{
    case amountRequired, amountOutOfRange, inquiryFailed
}

public enum TransferPhase: Equatable, Sendable
{
    case editing(TransferDraft, TransferFieldError?)
    case inquiring(TransferDraft)
    case reviewing(TransferQuote)
    case authorizing(TransferQuote, isBusy: Bool, isRejected: Bool)
    case submitting(TransferQuote)
    case pending(TransferQuote)
    case succeeded(TransferReceipt)
    case cancelled(TransferDraft)

    public var isTerminal: Bool
    {
        switch self
        {
        case .succeeded, .cancelled:
            return true
        default:
            return false
        }
    }

    public var draft: TransferDraft
    {
        switch self
        {
        case let .editing(draft, _), let .inquiring(draft), let .cancelled(draft):
            return draft
        case let .reviewing(quote), let .authorizing(quote, _, _), let .submitting(quote), let .pending(quote):
            return quote.inquiry.draft
        case let .succeeded(receipt):
            return receipt.quote.inquiry.draft
        }
    }

    /// History never restores an authorization screen or transient authorization data.
    public var safeSnapshot: TransferPhase
    {
        switch self
        {
        case let .authorizing(quote, _, _):
            return .reviewing(quote)
        case let .inquiring(draft):
            return .editing(draft, nil)
        case let .submitting(quote):
            return .pending(quote)
        default:
            return self
        }
    }
}

extension TransferFieldError: Equatable
{
}

public struct TransferSnapshot: Equatable, Sendable
{
    public let intent: TransferIntent
    public let revision: Int
    public let phase: TransferPhase
    public init(intent: TransferIntent, revision: Int, phase: TransferPhase)
    {
        self.intent = intent
        self.revision = revision
        self.phase = phase.safeSnapshot
    }
}

public enum TransferServiceError: Error
{
    case inquiryFailed, authorizationRejected, unavailable, uncertain
}
