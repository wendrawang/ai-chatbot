//
//  TanyaAIUseCase.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation
import TanyaAI

/// Sandbox: menerima draft tanpa backend. `--reject-send` menolak draft;
/// `--offline` melaporkan error tidak ada internet ke view model; `--broken-icons` membuat ikon shortcut gagal.
final class TanyaAIUseCase {
    let callback = BaseCallback()
    private let options: SandboxOptions

    init(options: SandboxOptions = .current) {
        self.options = options
    }

    /// true = draft diterima host; false = draft tetap di composer.
    func send(_ text: String) -> Bool {
        // TODO: Panggil service chat host setelah contract BE tersedia.
        guard !options.isOffline else {
            callback.onSubmissionFailed(URLError(.notConnectedToInternet))
            return false
        }
        return !options.isRejectingSend
    }

    /// Isi halaman sambutan dari fixture. Nil pada mode `--header-demo` (area scroll berisi konten contoh)
    /// atau bila fixture rusak, sehingga halaman tetap terbuka tanpa sambutan.
    func loadWelcome() -> WelcomeContent? {
        // TODO: Panggil inquiry init Tanya AI milik host setelah API tersedia.
        guard !options.isHeaderDemo, let url = SandboxFixtureFile.tanyaAIInitDummy.url,
            let data = try? Data(contentsOf: url)
        else { return nil }
        guard let welcome = try? JSONDecoder().decode(TanyaAIInitResponse.self, from: data).data else { return nil }
        return options.isIconBroken ? Self.breakingIcons(of: welcome) : welcome
    }

    /// `--broken-icons`: isi tetap dari fixture, hanya URL ikon diarahkan ke file yang tidak ada.
    private static func breakingIcons(of welcome: WelcomeContent) -> WelcomeContent {
        let shortcuts = welcome.shortcuts.map {
            WelcomeShortcut(
                title: $0.title, description: $0.description, iconURL: SandboxOptions.brokenIconURL, prompt: $0.prompt
            )
        }
        return WelcomeContent(greetings: welcome.greetings, shortcuts: shortcuts)
    }
}
