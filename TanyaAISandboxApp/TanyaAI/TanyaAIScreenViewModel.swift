//
//  TanyaAIScreenViewModel.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation
import TanyaAI

/// View model halaman Tanya AI di host: menyusun konfigurasi package dan meneruskan error service ke blocker.
final class TanyaAIScreenViewModel: ScreenContentViewModel {
    private let options: SandboxOptions
    /// Dibuat saat pertama dipakai agar error service bisa diteruskan ke blocker halaman ini.
    private(set) lazy var useCase = TanyaAIUseCase(options: options) { [weak self] error in
        Task { @MainActor in self?.didReceiveError(error) }
    }

    init(options: SandboxOptions = .current) {
        self.options = options
        super.init()
    }

    /// Bahasa dan theme yang aktif saat halaman dibuat.
    @MainActor
    func makeHost() -> TanyaAIHost {
        // Sandbox: bahasa dari launch option; host memakai Localize_Swift.
        TanyaAIHost(locale: options.locale ?? .current, service: useCase.service)
    }
}
