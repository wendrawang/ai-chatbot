//
//  MessageComposer.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI

public struct MessageComposer: View
{
    @Binding private var text: String
    private let placeholder: String
    private let sendLabel: String
    private let onSend: () -> Void
    public init(text: Binding<String>, placeholder: String, sendLabel: String, onSend: @escaping () -> Void)
    {
        _text = text
        self.placeholder = placeholder
        self.sendLabel = sendLabel
        self.onSend = onSend
    }

    public var body: some View
    {
        HStack(alignment: .bottom, spacing: FigmaSize.spacingMedium)
        {
            field.padding(.vertical, tapInset)
                .frame(minHeight: CustomSizes.minimumTap)
            Button(action: onSend)
            {
                Image(systemName: "arrow.up").font(Font(DesignTypography.composer).weight(.bold))
                    .foregroundColor(CustomColors.palette.colorsTextPrimaryLight)
                    .frame(width: CustomSizes.icon, height: CustomSizes.icon)
                    .background(isSendEnabled ? CustomColors.accent : CustomColors.palette.colorsButtonDisable)
                    .clipShape(Circle())
                    .frame(width: CustomSizes.minimumTap, height: CustomSizes.minimumTap)
                    .contentShape(Rectangle())
            }

            .buttonStyle(.plain).disabled(!isSendEnabled).accessibilityLabel(sendLabel)
        }

        .padding(.leading, FigmaSize.spacingLarge)
        .padding(.trailing, FigmaSize.spacingLarge - tapInset)
        .padding(.vertical, FigmaSize.spacingLarge - tapInset)
        .background(CustomColors.background)
        .cornerRadius(CustomSizes.radius)
        .overlay(RoundedRectangle(cornerRadius: CustomSizes.radius)
            .stroke(CustomColors.divider, lineWidth: CustomSizes.stroke))
    }

    private var tapInset: CGFloat
    {
        (CustomSizes.minimumTap - CustomSizes.icon) / 2
    }

    private var isSendEnabled: Bool
    {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var field: some View
    {
        ZStack(alignment: .leading)
        {
            GrowingTextInput(
                text: $text,
                font: DesignTypography.composer,
                textColor: UIColor(CustomColors.text),
                accessibilityLabel: placeholder)
                .fixedSize(horizontal: false, vertical: true).frame(maxWidth: .infinity)
            if text.isEmpty
            {
                Text(placeholder).font(Font(DesignTypography.composer)).lineLimit(1)
                    .foregroundColor(CustomColors.secondaryText).allowsHitTesting(false).accessibilityHidden(true)
            }
        }
    }
}
