//
//  PrimaryButton.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI

public struct PrimaryButton: View
{
    private let title: String
    private let isEnabled: Bool
    private let action: () -> Void
    public init(_ title: String, isEnabled: Bool, action: @escaping () -> Void)
    {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View
    {
        Button(action: action)
        {
            Text(title).font(Font(DesignTypography.body()).weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: CustomSizes.minimumTap)
                .foregroundColor(CustomColors.palette.colorsTextPrimaryLight)
                .background(isEnabled ? CustomColors.accent : CustomColors.palette.colorsButtonDisable)
                .cornerRadius(CustomSizes.radius)
        }

        .buttonStyle(.plain).disabled(!isEnabled)
    }
}
