//
//  TanyaAIDestination.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI

/// Pemilik view model halaman Tanya AI. Autoclosure `@StateObject` dijalankan sekali saat halaman di-push:
/// UseCase dibuat, input ditulis, lalu view model dibuat. Render ulang coordinator tidak membuat ulang keduanya.
@MainActor
struct TanyaAIDestination: View {
    @StateObject
    private var viewModel: TanyaAIScreenViewModel
    let onBack: () -> Void

    init(initData: TanyaAIInitData?, onBack: @escaping () -> Void) {
        _viewModel = StateObject(
            wrappedValue: {
                let useCase = TanyaAIUseCase()
                useCase.input.initData = initData
                return TanyaAIScreenViewModel(useCase: useCase)
            }())
        self.onBack = onBack
    }

    var body: some View {
        Screen {
            TanyaAIScreen(viewModel: viewModel, onBack: onBack)
        }
    }
}
