//
//  DetailScreenViewModel.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation

/// Tiruan view model halaman detail.
final class DetailScreenViewModel: ScreenContentViewModel {
    let entryUseCase = TanyaAIEntryUseCase()

    func openTanyaAI() {
        entryUseCase.inquire()
    }
}
