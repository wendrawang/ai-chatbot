//
//  TransferFormatting.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import TanyaAIDomain

struct TransferFormatting
{
    let locale: Locale
    func money(_ value: Money) -> String
    {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.currencyCode = value.currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: value.amount)) ?? value.currency
    }

    func amountInput(_ amount: Decimal?) -> String
    {
        guard let amount
        else
        {
            return ""
        }

        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? ""
    }

    func parseAmount(_ text: String) -> Decimal?
    {
        guard !text.isEmpty, text.allSatisfy(
            {
                $0.isASCII && $0.isNumber
            })
        else
        {
            return nil
        }

        return Decimal(string: text, locale: Locale(identifier: "en_US_POSIX"))
    }

    func date(_ date: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
