//
//  TransferFlowViewModel.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import Combine
import Foundation
import TanyaAIDomain

@MainActor
final class TransferFlowViewModel: ObservableObject
{
    let service: TransferServicing
    let authorizer: TransactionAuthorizing
    let configuration: TransferConfiguration
    let intent: TransferIntent
    @Published private(set) var phase: TransferPhase
    @Published var isCheckingStatus: Bool
    @Published var isStatusFailed: Bool
    var revision: Int
    var onChange: ((TransferSnapshot) -> Void)?
    var operation: Task<Void, Never>?
    init(
        snapshot: TransferSnapshot,
        service: TransferServicing,
        authorizer: TransactionAuthorizing,
        configuration: TransferConfiguration)
    {
        self.service = service
        self.authorizer = authorizer
        self.configuration = configuration
        intent = snapshot.intent
        revision = snapshot.revision
        phase = snapshot.phase
        isCheckingStatus = false
        isStatusFailed = false
    }

    deinit
    {
        operation?.cancel()
    }

    func continueTapped()
    {
        guard case let .editing(draft, _) = phase
        else
        {
            return
        }

        guard let amount = draft.amount
        else
        {
            transition(.editing(draft, .amountRequired))
            return
        }

        guard amount > 0, amount >= configuration.minimumAmount, amount <= configuration.maximumAmount
        else
        {
            transition(.editing(draft, .amountOutOfRange))
            return
        }

        let request = TransferInquiry(
            flowID: intent.flowID,
            sessionID: intent.sessionID,
            revision: revision,
            draft: draft)
        transition(.inquiring(draft))
        operation = Task
        {
            [weak self] in
            await self?.performInquiry(request)
        }
    }

    func editTapped()
    {
        guard case let .reviewing(quote) = phase
        else
        {
            return
        }

        revision += 1
        transition(.editing(quote.inquiry.draft, nil))
    }

    func confirmTapped()
    {
        guard case let .reviewing(quote) = phase
        else
        {
            return
        }

        transition(.authorizing(quote, isBusy: false, isRejected: false))
    }

    func pinBackTapped()
    {
        guard case let .authorizing(quote, isBusy, _) = phase
        else
        {
            return
        }

        guard !isBusy
        else
        {
            operation?.cancel()
            revision += 1
            transition(.editing(quote.inquiry.draft, nil))
            return
        }

        transition(.reviewing(quote))
    }

    func authorizeCompleted()
    {
        guard case .authorizing(let quote, false, _) = phase
        else
        {
            return
        }

        transition(.authorizing(quote, isBusy: true, isRejected: false))
        operation = Task
        {
            [weak self] in
            await self?.performAuthorization(quote)
        }
    }

    func cancelTapped()
    {
        switch phase
        {
        case .editing, .inquiring, .reviewing, .authorizing:
            let draft = phase.draft
            revision += 1
            operation?.cancel()
            transition(.cancelled(draft))
        default:
            return
        }
    }

    func retryStatusCheck()
    {
        guard case let .pending(quote) = phase, !isCheckingStatus
        else
        {
            return
        }

        isCheckingStatus = true
        isStatusFailed = false
        operation = Task
        {
            [weak self] in
            await self?.performStatusCheck(quote)
        }
    }

    func transition(_ next: TransferPhase)
    {
        phase = next
        onChange?(TransferSnapshot(intent: intent, revision: revision, phase: next))
    }
}
