//
//  SandboxRouter.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 15/10/26.
//

import TanyaAI
import UIKit

/// Peran host: memiliki `TanyaAIHost`, mem-push halamannya ke jalur navigasi revamp,
/// dan membuka link dari jawaban (webview, deeplink, telepon).
@MainActor
final class SandboxRouter {
    weak var navigation: UINavigationController?
    private var tanyaAI: TanyaAIHost?
    private weak var tanyaAIPage: UIViewController?

    init(options: SandboxOptions) {
        let locale = options.locale ?? .current
        tanyaAI = TanyaAIHost(
            customerName: String(resource: R.string.localizable.sandboxCustomerName, locale: locale),
            service: SandboxChatService(), locale: locale
        ) { [weak self] link in self?.open(link) }
    }

    func openTanyaAI() {
        // Ketukan ganda tidak mem-push halaman kedua.
        guard tanyaAIPage == nil, let navigation, let page = tanyaAI?.makeViewController() else { return }
        tanyaAIPage = page
        navigation.pushViewController(page, animated: true)
    }
}

// MARK: - Actions

private extension SandboxRouter {
    func open(_ link: TanyaAILink) {
        switch link {
        case .web(let url): navigation?.pushViewController(SandboxWebViewController(url: url), animated: true)
        case .deeplink(let url), .phone(let url): UIApplication.shared.open(url)
        }
    }
}
