//
//  TransferSummaryView.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI
import TanyaAIDomain

struct TransferSummaryView: View
{
    let quote: TransferQuote
    let copy: FeatureCopy
    let onChangeSource: () -> Void
    let onConfirm: () -> Void
    let onEdit: () -> Void
    let onCancel: () -> Void
    private var format: TransferFormatting
    {
        TransferFormatting(locale: copy.locale)
    }

    var body: some View
    {
        Text(copy.summaryTitle).font(Font(DesignTypography.heading()))
        HStack
        {
            Text(copy.source)
            Spacer()
            Button(copy.change, action: onChangeSource).frame(minHeight: CustomSizes.minimumTap)
        }

        AccountRow(account: quote.inquiry.draft.source)
        Divider()
        Text(copy.recipient).foregroundColor(CustomColors.secondaryText)
        AccountRow(account: quote.inquiry.draft.recipient)
        Divider()
        TransferQuoteDetails(quote: quote, copy: copy)
        PrimaryButton(copy.confirm, isEnabled: true, action: onConfirm)
        Button(copy.edit, action: onEdit).frame(minHeight: CustomSizes.minimumTap)
        Button(copy.cancel, action: onCancel).frame(minHeight: CustomSizes.minimumTap)
        UnavailableControl(title: copy.additional, explanation: copy.unavailable)
    }
}

struct TransferQuoteDetails: View
{
    let quote: TransferQuote
    let copy: FeatureCopy
    private var format: TransferFormatting
    {
        TransferFormatting(locale: copy.locale)
    }

    var body: some View
    {
        TransferDetailRow(title: copy.amount, value: format.money(quote.amount))
        fee
        if let remaining = quote.benefitRemaining, let total = quote.benefitTotal
        {
            Text(copy.benefit(remaining, total)).foregroundColor(CustomColors.success)
        }

        TransferDetailRow(title: copy.method, value: quote.inquiry.draft.method)
        TransferDetailRow(title: copy.time, value: copy.now)
        TransferDetailRow(title: copy.purpose, value: copy.fundTransfer)
        if !quote.inquiry.draft.note.isEmpty
        {
            TransferDetailRow(title: copy.note, value: quote.inquiry.draft.note)
        }

        Divider()
        TransferDetailRow(title: copy.total, value: format.money(quote.total))
            .font(Font(DesignTypography.body()).weight(.semibold))
    }

    private var fee: some View
    {
        VStack(alignment: .leading, spacing: FigmaSize.spacingSmall)
        {
            Text(copy.fee).foregroundColor(CustomColors.secondaryText)
            if quote.originalFee.amount != quote.effectiveFee.amount
            {
                Text(format.money(quote.originalFee)).strikethrough().foregroundColor(CustomColors.secondaryText)
            }

            Text(format.money(quote.effectiveFee)).frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
