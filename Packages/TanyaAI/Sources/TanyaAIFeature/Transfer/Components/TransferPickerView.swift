//
//  TransferPickerView.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI
import TanyaAIDomain

enum TransferPicker: String, Identifiable
{
    case method, purpose, source
    var id: String
    {
        rawValue
    }
}

struct TransferPickerView: View
{
    let selection: TransferPicker
    @ObservedObject var model: TransferFlowViewModel
    let copy: FeatureCopy
    let onClose: () -> Void
    var body: some View
    {
        VStack(alignment: .leading, spacing: FigmaSize.spacingLarge)
        {
            Text(copy.pickerTitle).font(Font(DesignTypography.heading()))
            List
            {
                options
            }

            Button(copy.done, action: onClose).frame(minHeight: CustomSizes.minimumTap)
        }

        .padding(FigmaSize.spacingLarge)
    }

    @ViewBuilder private var options: some View
    {
        switch selection
        {
        case .method:
            ForEach(model.configuration.methods, id: \.self)
            {
                value in
                option(value, isSelected: value == model.phase.draft.method)
                {
                    model.selectMethod(value)
                }
            }

        case .purpose:
            ForEach(model.configuration.purposes, id: \.self)
            {
                value in
                option(copy.fundTransfer, isSelected: value == model.phase.draft.purpose)
                {
                    model.selectPurpose(value)
                }
            }

        case .source:
            ForEach(model.configuration.sourceAccounts)
            {
                account in
                Button
                {
                    model.selectSource(account)
                    onClose()
                }

                label:
                {
                    HStack
                    {
                        AccountRow(account: account)
                        if account.id == model.phase.draft.source.id
                        {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }

    private func option(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View
    {
        Button
        {
            action()
            onClose()
        }

        label:
        {
            HStack
            {
                Text(title)
                Spacer()
                if isSelected
                {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
