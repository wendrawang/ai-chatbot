//
//  SandboxRouter.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 18/10/26.
//

import TanyaAI
import UIKit

/// Peran host: memiliki `TanyaAIHost` dan mem-push halamannya ke jalur navigasi revamp.
@MainActor
final class SandboxRouter {
    weak var navigation: UINavigationController?
    private let tanyaAI: TanyaAIHost
    private let isHeaderDemo: Bool
    private weak var tanyaAIPage: UIViewController?

    init(options: SandboxOptions) {
        tanyaAI = TanyaAIHost(locale: options.locale ?? .current) { _ in !options.isRejectingSend }
        isHeaderDemo = options.isHeaderDemo
    }

    func openTanyaAI() {
        // Ketukan ganda tidak mem-push halaman kedua.
        guard tanyaAIPage == nil, let navigation else { return }
        let page = isHeaderDemo ? tanyaAI.makeViewController { HeaderDemoContent() } : tanyaAI.makeViewController()
        tanyaAIPage = page
        navigation.pushViewController(page, animated: true)
    }
}
