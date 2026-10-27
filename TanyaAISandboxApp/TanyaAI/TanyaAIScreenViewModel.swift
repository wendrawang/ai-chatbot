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
    @Published
    private(set) var welcome: WelcomeContent?
    /// Sejak chat diterima sampai jawaban datang; tombol kirim Tanya AI menjadi titik bergerak.
    @Published
    private(set) var isAwaitingReply = false

    init(useCase: TanyaAIUseCase = TanyaAIUseCase()) {
        self.useCase = useCase
        super.init()
        useCase.callback.onSubmissionFailed = { [weak self] error in self?.didReceiveError(error) }
        welcome = useCase.loadWelcome()
    }

    /// Chat dari composer atau shortcut. Diterima = mulai menunggu jawaban.
    func send(_ text: String) -> Bool {
        let isAccepted = useCase.send(text)
        // TODO: Akhiri penantian saat jawaban dari stream datang; sandbox menunggu sampai percakapan baru.
        if isAccepted { isAwaitingReply = true }
        return isAccepted
    }

    func startNewConversation() {
        isAwaitingReply = false
    }

    /// Bahasa dan theme yang aktif saat halaman dibuat.
    @MainActor
    func makeHost() -> TanyaAIHost {
        // Sandbox: bahasa dari launch option; host memakai Localize_Swift.
        TanyaAIHost(
            locale: SandboxOptions.current.locale ?? .current, isAwaitingReply: isAwaitingReply, welcome: welcome,
            onNewConversation: { [weak self] in self?.startNewConversation() },
            onSend: { [weak self] text in self?.send(text) ?? false }
        )
    }
}
