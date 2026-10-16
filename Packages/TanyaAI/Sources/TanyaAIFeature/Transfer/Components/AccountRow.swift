//
//  AccountRow.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI
import TanyaAIDomain

struct AccountRow: View
{
    let account: Account
    var body: some View
    {
        HStack(alignment: .top, spacing: FigmaSize.spacingMedium)
        {
            Text(String(account.name.prefix(1)))
                .font(Font(DesignTypography.heading()))
                .frame(width: CustomSizes.avatar, height: CustomSizes.avatar)
                .background(CustomColors.palette.colorsSurfaceSelected).clipShape(Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: FigmaSize.spacingSmall)
            {
                Text(account.name).fontWeight(.semibold)
                Text(account.bank)
                Text(account.maskedNumber).foregroundColor(CustomColors.secondaryText)
            }

            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct TransferDetailRow: View
{
    let title: String
    let value: String
    var body: some View
    {
        VStack(alignment: .leading, spacing: FigmaSize.spacingSmall)
        {
            Text(title).foregroundColor(CustomColors.secondaryText)
            Text(value).frame(maxWidth: .infinity, alignment: .trailing)
        }

        .padding(.vertical, FigmaSize.spacingSmall)
    }
}

struct UnavailableControl: View
{
    let title: String
    let explanation: String
    var body: some View
    {
        VStack(alignment: .leading, spacing: FigmaSize.spacingSmall)
        {
            Button(title)
            {
            }

            .disabled(true)
            Text(explanation).foregroundColor(CustomColors.secondaryText)
        }

        .accessibilityElement(children: .combine)
    }
}
