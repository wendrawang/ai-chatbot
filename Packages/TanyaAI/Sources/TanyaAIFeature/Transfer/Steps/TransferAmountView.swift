//
//  TransferAmountView.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI
import TanyaAIDomain

struct TransferAmountView: View
{
    @State private var amountText: String
    let draft: TransferDraft
    let error: TransferFieldError?
    let configuration: TransferConfiguration
    let copy: FeatureCopy
    let onAmount: (Decimal?) -> Void
    let onNote: (String) -> Void
    let onPicker: (TransferPicker) -> Void
    let onContinue: () -> Void
    let onCancel: () -> Void
    init(
        draft: TransferDraft,
        error: TransferFieldError?,
        configuration: TransferConfiguration,
        copy: FeatureCopy,
        onAmount: @escaping (Decimal?) -> Void,
        onNote: @escaping (String) -> Void,
        onPicker: @escaping (TransferPicker) -> Void,
        onContinue: @escaping () -> Void,
        onCancel: @escaping () -> Void)
    {
        self.draft = draft
        self.error = error
        self.configuration = configuration
        self.copy = copy
        self.onAmount = onAmount
        self.onNote = onNote
        self.onPicker = onPicker
        self.onContinue = onContinue
        self.onCancel = onCancel
        _amountText = State(initialValue: TransferFormatting(locale: copy.locale).amountInput(draft.amount))
    }

    var body: some View
    {
        Text(copy.amountTitle).font(Font(DesignTypography.heading()))
        AccountRow(account: draft.recipient)
        Divider()
        TextField(copy.amount, text: $amountText)
            .keyboardType(.numberPad).font(Font(DesignTypography.amount()))
            .accessibilityLabel(copy.amount)
            .onChange(of: amountText)
            {
                onAmount(TransferFormatting(locale: copy.locale).parseAmount($0))
            }

        if let error
        {
            Text(errorText(error)).foregroundColor(CustomColors.accent)
        }

        Divider()
        Button
        {
            onPicker(.method)
        }

        label:
        {
            TransferDetailRow(title: copy.method, value: draft.method)
        }

        Button
        {
            onPicker(.purpose)
        }

        label:
        {
            TransferDetailRow(title: copy.purpose, value: copy.fundTransfer)
        }

        note
        UnavailableControl(title: copy.sendGreeting, explanation: copy.unavailable)
        Text(copy.now).fontWeight(.semibold)
        UnavailableControl(title: copy.scheduled, explanation: copy.unavailable)
        UnavailableControl(title: copy.recurring, explanation: copy.unavailable)
        PrimaryButton(copy.continueAction, isEnabled: true, action: onContinue)
        Button(copy.cancel, action: onCancel).frame(minHeight: CustomSizes.minimumTap)
    }

    private var note: some View
    {
        VStack(alignment: .leading, spacing: FigmaSize.spacingSmall)
        {
            TextField(copy.note, text: Binding(
                get:
                {
                    draft.note
                },

                set: onNote))
                .accessibilityLabel(copy.note)
            Text(copy.noteCount(draft.note.count, configuration.noteLimit))
                .foregroundColor(CustomColors.secondaryText)
        }
    }

    private func errorText(_ error: TransferFieldError) -> String
    {
        switch error
        {
        case .amountRequired:
            return copy.required
        case .amountOutOfRange:
            return copy.range
        case .inquiryFailed:
            return copy.inquiryFailed
        }
    }
}
