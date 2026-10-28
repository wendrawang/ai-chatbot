//
//  TanyaAIScreenViewModel.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation
import TanyaAI

/// View model halaman Tanya AI di host: menyusun konfigurasi package dan meneruskan kiriman ke use case.
/// Status menunggu jawaban milik TanyaAI (`TanyaAIBridge`), bukan view model ini.
final class TanyaAIScreenViewModel: ScreenContentViewModel {
    let useCase: TanyaAIUseCase
    @Published
    private(set) var welcome: WelcomeContent?
    /// Dibuat sekali bersama view model (milik `@StateObject` destination) dan dipakai ulang setiap render.
    @MainActor
    private(set) lazy var bridge = TanyaAIBridge(
        onNewConversation: { [weak self] in self?.startNewConversation() },
        onSend: { [weak self] text in self?.send(text) ?? false }
    )

    init(useCase: TanyaAIUseCase = TanyaAIUseCase()) {
        self.useCase = useCase
        super.init()
        useCase.callback.onSubmissionFailed = { [weak self] error in self?.didReceiveError(error) }
        welcome = useCase.loadWelcome()
    }

    /// Chat dari composer atau shortcut; true = diterima host.
    func send(_ text: String) -> Bool {
        // TODO: Kirim lewat API chat host; jawaban datang dari SSE yang diteruskan ke `bridge`.
        useCase.send(text)
    }

    /// TODO: Init ulang sesi dan stream milik host; sandbox hanya memuat ulang sambutan.
    func startNewConversation() {
        welcome = useCase.loadWelcome()
    }

    /// Bahasa dan theme yang aktif saat halaman dibuat.
    @MainActor
    func makeHost() -> TanyaAIHost {
        // Sandbox: bahasa dari launch option; host memakai Localize_Swift.
        TanyaAIHost(locale: SandboxOptions.current.locale ?? .current, welcome: welcome, bridge: bridge)
    }
}
