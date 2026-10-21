//
//  TanyaAIScreenViewModel.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation
import TanyaAI
import UIKit

/// View model halaman Tanya AI di host: menyusun konfigurasi package, membuka link jawaban,
/// dan meneruskan error service ke blocker host.
final class TanyaAIScreenViewModel: ScreenContentViewModel {
    @Published
    var webLink: URL?
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
        let locale = SandboxOptions.current.locale ?? .current
        return TanyaAIHost(
            customerName: String(resource: R.string.localizable.sandboxCustomerName, locale: locale),
            service: useCase.service, locale: locale
        ) { [weak self] link in self?.open(link) }
    }

    /// Link web ke webview host; deeplink dan telepon ke handler sistem/host.
    @MainActor
    func open(_ link: TanyaAILink) {
        switch link {
        case .web(let url): webLink = url
        case .deeplink(let url), .phone(let url): UIApplication.shared.open(url)
        }
    }
}
