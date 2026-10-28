//
//  TanyaAIScreenViewModel.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation
import TanyaAI

/// View model halaman Tanya AI di host: menyusun konfigurasi package dan transport chat milik host.
/// Urutan init → history → SSE, retry, pesan, dan status menunggu jawaban milik TanyaAI (`TanyaAIBridge`).
final class TanyaAIScreenViewModel: ScreenContentViewModel {
    let useCase: TanyaAIUseCase
    @Published
    private(set) var welcome: WelcomeContent?
    /// Dibuat sekali bersama view model (milik `@StateObject` destination) dan dipakai ulang setiap render.
    @MainActor
    private(set) lazy var bridge = TanyaAIBridge(
        transport: useCase.makeChatTransport(),
        onSessionExpired: { [weak self] in self?.didReceiveError(URLError(.userAuthenticationRequired)) }
    )

    init(useCase: TanyaAIUseCase = TanyaAIUseCase()) {
        self.useCase = useCase
        super.init()
        useCase.callback.onSubmissionFailed = { [weak self] error in self?.didReceiveError(error) }
        welcome = useCase.loadWelcome()
    }

    /// Bahasa dan theme yang aktif saat halaman dibuat.
    @MainActor
    func makeHost() -> TanyaAIHost {
        // Sandbox: bahasa dari launch option; host memakai Localize_Swift.
        TanyaAIHost(locale: SandboxOptions.current.locale ?? .current, welcome: welcome, bridge: bridge)
    }
}
