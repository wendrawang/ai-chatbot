//
//  TransferFlowViewModel+Requests.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import TanyaAIDomain

extension TransferFlowViewModel
{
    func performInquiry(_ request: TransferInquiry) async
    {
        do
        {
            let quote = try await service.inquiry(request)
            guard isCurrent(request), case .inquiring = phase,
                  quote.inquiry == request
            else
            {
                return
            }

            transition(.reviewing(quote))
        }

        catch
        {
            guard isCurrent(request), case .inquiring = phase
            else
            {
                return
            }

            transition(.editing(request.draft, .inquiryFailed))
        }
    }

    func performAuthorization(_ quote: TransferQuote) async
    {
        do
        {
            let request = AuthorizationRequest(flowID: intent.flowID, quoteID: quote.id)
            let grant = try await authorizer.authorize(request)
            guard isCurrent(quote.inquiry), case .authorizing(_, true, _) = phase
            else
            {
                return
            }

            transition(.submitting(quote))
            await performSubmit(quote, grant: grant)
        }

        catch
        {
            guard isCurrent(quote.inquiry), case .authorizing = phase
            else
            {
                return
            }

            transition(.authorizing(quote, isBusy: false, isRejected: true))
        }
    }

    private func performSubmit(_ quote: TransferQuote, grant: AuthorizationGrant) async
    {
        let command = TransferCommand(id: commandID(quote), quote: quote, authorization: grant)
        do
        {
            let result = try await service.submit(command)
            guard isCurrent(quote.inquiry), case .submitting = phase
            else
            {
                return
            }

            accept(result, quote: quote)
        }

        catch
        {
            guard isCurrent(quote.inquiry), case .submitting = phase
            else
            {
                return
            }

            // A lost acknowledgement is uncertain; a new submit would risk duplicating it.
            transition(.pending(quote))
        }
    }

    func performStatusCheck(_ quote: TransferQuote) async
    {
        defer
        {
            isCheckingStatus = false
        }

        do
        {
            let result = try await service.status(commandID: commandID(quote), quote: quote)
            guard isCurrent(quote.inquiry), case .pending = phase
            else
            {
                return
            }

            accept(result, quote: quote)
        }

        catch
        {
            isStatusFailed = true
        }
    }

    private func accept(_ result: TransferSubmission, quote: TransferQuote)
    {
        switch result
        {
        case let .succeeded(receipt):
            guard receipt.commandID == commandID(quote), receipt.quote == quote
            else
            {
                transition(.pending(quote))
                return
            }

            transition(.succeeded(receipt))
        case .pending:
            transition(.pending(quote))
        }
    }

    private func commandID(_ quote: TransferQuote) -> String
    {
        intent.flowID + "/" + quote.id
    }

    private func isCurrent(_ request: TransferInquiry) -> Bool
    {
        request.flowID == intent.flowID && request.sessionID == intent.sessionID && request.revision == revision
    }
}
