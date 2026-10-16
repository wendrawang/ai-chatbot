//
//  TransferReceiptView.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI
import TanyaAIDomain

struct TransferReceiptView: View
{
    let receipt: TransferReceipt
    let brand: String
    let copy: FeatureCopy
    let onBack: () -> Void
    private var format: TransferFormatting
    {
        TransferFormatting(locale: copy.locale)
    }

    var body: some View
    {
        // TODO: Replace the demo wordmark with the approved brand asset when supplied.
        Text(brand).font(Font(DesignTypography.heading()))
        Text(copy.demo).foregroundColor(CustomColors.secondaryText)
        Image(systemName: "checkmark.circle.fill").foregroundColor(CustomColors.success)
            .font(Font(DesignTypography.amount())).accessibilityHidden(true)
        Text(copy.receiptTitle).font(Font(DesignTypography.heading()))
        TransferDetailRow(title: copy.source, value: receipt.quote.inquiry.draft.source.maskedNumber)
        AccountRow(account: receipt.quote.inquiry.draft.recipient)
        Divider()
        TransferDetailRow(title: copy.date, value: format.date(receipt.completedAt))
        TransferQuoteDetails(quote: receipt.quote, copy: copy)
        TransferDetailRow(title: copy.transferDate, value: format.date(receipt.quote.date))
        TransferDetailRow(title: copy.reference, value: receipt.reference)
        PrimaryButton(copy.back, isEnabled: true, action: onBack)
        UnavailableControl(title: copy.share, explanation: copy.unavailable)
    }
}
