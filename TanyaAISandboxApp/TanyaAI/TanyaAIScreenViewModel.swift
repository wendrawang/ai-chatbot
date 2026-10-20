//
//  TanyaAIScreenViewModel.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation
import TanyaAI

/// View model halaman Tanya AI di host: menyusun konfigurasi package dan meneruskan kiriman ke use case.
final class TanyaAIScreenViewModel: ScreenContentViewModel {
    let useCase: TanyaAIUseCase

    init(useCase: TanyaAIUseCase = TanyaAIUseCase()) {
        self.useCase = useCase
        super.init()
        useCase.callback.onSubmissionFailed = { [weak self] error in self?.didReceiveError(error) }
    }

    /// Bahasa dan theme yang aktif saat halaman dibuat.
    @MainActor
    func makeHost() -> TanyaAIHost {
        // Sandbox: bahasa dari launch option; host memakai Localize_Swift.
        TanyaAIHost(locale: SandboxOptions.current.locale ?? .current) { [weak self] text in
            self?.useCase.send(text) ?? false
        }
    }
}
