//
//  TransferFlowViewModel+Draft.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import TanyaAIDomain

extension TransferFlowViewModel
{
    func updateAmount(_ amount: Decimal?)
    {
        mutateDraft
        {
            $0.amount = amount
        }
    }

    func updateNote(_ note: String)
    {
        mutateDraft
        {
            $0.note = String(note.prefix(configuration.noteLimit))
        }
    }

    func selectMethod(_ method: String)
    {
        guard configuration.methods.contains(method)
        else
        {
            return
        }

        mutateDraft
        {
            $0.method = method
        }
    }

    func selectPurpose(_ purpose: String)
    {
        guard configuration.purposes.contains(purpose)
        else
        {
            return
        }

        mutateDraft
        {
            $0.purpose = purpose
        }
    }

    func selectSource(_ source: Account)
    {
        guard configuration.sourceAccounts.contains(source)
        else
        {
            return
        }

        switch phase
        {
        case .editing, .reviewing:
            mutateEditableSource(source)
        default:
            return
        }
    }

    private func mutateDraft(_ update: (inout TransferDraft) -> Void)
    {
        guard case var .editing(draft, _) = phase
        else
        {
            return
        }

        update(&draft)
        revision += 1
        transition(.editing(draft, nil))
    }

    private func mutateEditableSource(_ source: Account)
    {
        var draft = phase.draft
        draft.source = source
        revision += 1
        transition(.editing(draft, nil))
    }
}
