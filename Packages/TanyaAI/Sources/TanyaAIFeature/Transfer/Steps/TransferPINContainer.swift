//
//  TransferPINContainer.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI

struct TransferPINContainer: View
{
    @StateObject private var input: PINInput
    let length: Int
    let isBusy: Bool
    let isRejected: Bool
    let copy: FeatureCopy
    let onBack: () -> Void
    let onCancel: () -> Void
    init(
        length: Int,
        isBusy: Bool,
        isRejected: Bool,
        copy: FeatureCopy,
        onComplete: @escaping () -> Void,
        onBack: @escaping () -> Void,
        onCancel: @escaping () -> Void)
    {
        self.length = length
        self.isBusy = isBusy
        self.isRejected = isRejected
        self.copy = copy
        self.onBack = onBack
        self.onCancel = onCancel
        _input = StateObject(wrappedValue: PINInput(length: length, onComplete: onComplete))
    }

    var body: some View
    {
        Text(copy.pinTitle).font(Font(DesignTypography.heading()))
        Text(copy.pinHelp(length))
        Text(String(repeating: "● ", count: input.digits.count) + String(
            repeating: "○ ",
            count: length - input.digits.count))
            .font(Font(DesignTypography.heading()))
            .accessibilityLabel(copy.pinProgress(input.digits.count, length))
        if isRejected
        {
            Text(copy.pinRejected).foregroundColor(CustomColors.accent)
        }

        if isBusy
        {
            ProgressView()
        }

        keypad.disabled(isBusy)
        Button(copy.back)
        {
            input.clear()
            onBack()
        }

        .disabled(isBusy).frame(minHeight: CustomSizes.minimumTap)
        Button(copy.cancel)
        {
            input.clear()
            onCancel()
        }

        .frame(minHeight: CustomSizes.minimumTap)
        .onDisappear
        {
            input.clear()
        }

        .onChange(of: isRejected)
        {
            isRejected in
            guard isRejected
            else
            {
                return
            }

            input.clear()
        }
    }

    private var keypad: some View
    {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: FigmaSize.spacingMedium)
        {
            ForEach(1 ... 9, id: \.self)
            {
                number in
                digit(number)
            }

            Color.clear.frame(height: CustomSizes.minimumTap)
            digit(0)
            Button(action: input.delete)
            {
                Image(systemName: "delete.left").frame(maxWidth: .infinity, minHeight: CustomSizes.minimumTap)
            }

            .accessibilityLabel(copy.delete)
        }
    }

    private func digit(_ number: Int) -> some View
    {
        Button
        {
            input.append(number)
        }

        label:
        {
            Text(String(number)).font(Font(DesignTypography.heading()))
                .frame(maxWidth: .infinity, minHeight: CustomSizes.minimumTap)
                .background(CustomColors.palette.colorsSurfaceSelected).clipShape(Capsule())
        }

        .buttonStyle(.plain)
    }
}
