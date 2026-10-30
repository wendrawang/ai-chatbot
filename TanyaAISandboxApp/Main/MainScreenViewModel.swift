//
//  MainScreenViewModel.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation

/// Tiruan view model main. Belum ada data; cukup state blocker dari base.
final class MainScreenViewModel: ScreenContentViewModel {
    let entryUseCase = TanyaAIEntryUseCase()

    func openTanyaAI() {
        entryUseCase.inquire()
    }
}
