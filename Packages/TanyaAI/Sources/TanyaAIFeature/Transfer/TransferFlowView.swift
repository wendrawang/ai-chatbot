//
//  TransferFlowView.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI
import TanyaAIDomain

struct TransferFlowView: View
{
    @ObservedObject var model: TransferFlowViewModel
    @State private var picker: TransferPicker?
    let copy: FeatureCopy
    let onFinished: () -> Void
    var body: some View
    {
        VStack(alignment: .leading, spacing: FigmaSize.spacingLarge)
        {
            stage
        }

        .font(Font(DesignTypography.body()))
        .foregroundColor(CustomColors.text)
        .padding(FigmaSize.spacingLarge)
        .background(CustomColors.background)
        .overlay(RoundedRectangle(cornerRadius: CustomSizes.radius)
            .stroke(CustomColors.divider, lineWidth: CustomSizes.stroke))
        .padding(FigmaSize.spacingLarge)
        .sheet(item: $picker)
        {
            selection in
            TransferPickerView(selection: selection, model: model, copy: copy)
            {
                picker = nil
            }
        }
    }

    @ViewBuilder private var stage: some View
    {
        switch model.phase
        {
        case let .editing(draft, error):
            TransferAmountView(
                draft: draft,
                error: error,
                configuration: model.configuration,
                copy: copy,
                onAmount: model.updateAmount,
                onNote: model.updateNote,
                onPicker:
                {
                    picker = $0
                },

                onContinue: model.continueTapped,
                onCancel: model.cancelTapped)
        case .inquiring:
            progress(copy.inquiring)
            Button(copy.cancel, action: model.cancelTapped)
        case let .reviewing(quote):
            TransferSummaryView(
                quote: quote,
                copy: copy,
                onChangeSource:
                {
                    picker = .source
                },

                onConfirm: model.confirmTapped,
                onEdit: model.editTapped,
                onCancel: model.cancelTapped)
        case let .authorizing(_, isBusy, isRejected):
            TransferPINContainer(
                length: model.configuration.pinLength,
                isBusy: isBusy,
                isRejected: isRejected,
                copy: copy,
                onComplete: model.authorizeCompleted,
                onBack: model.pinBackTapped,
                onCancel: model.cancelTapped)
        case .submitting:
            progress(copy.submitting)
        case .pending, .succeeded, .cancelled:
            terminalStage
        }
    }

    @ViewBuilder private var terminalStage: some View
    {
        switch model.phase
        {
        case .pending:
            Text(copy.pending)
            if model.isStatusFailed
            {
                Text(copy.statusFailed).foregroundColor(CustomColors.accent)
            }

            PrimaryButton(copy.checkStatus, isEnabled: !model.isCheckingStatus, action: model.retryStatusCheck)
        case let .succeeded(receipt):
            TransferReceiptView(receipt: receipt, brand: model.configuration.brandName, copy: copy, onBack: onFinished)
        case .cancelled:
            Text(copy.cancelled)
        default:
            EmptyView()
        }
    }

    private func progress(_ title: String) -> some View
    {
        HStack(spacing: FigmaSize.spacingMedium)
        {
            ProgressView()
            Text(title)
        }
    }
}
