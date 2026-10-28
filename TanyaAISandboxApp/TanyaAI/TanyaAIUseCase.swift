//
//  TanyaAIUseCase.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation
import TanyaAI

/// Sandbox: sambutan dari fixture dan gateway chat tiruan. `--offline` melaporkan error tidak ada internet
/// ke view model saat kirim; `--broken-icons`/`--slow-icons` membuat ikon shortcut gagal/tertahan loading.
final class TanyaAIUseCase {
    let callback = BaseCallback()
    private let options: SandboxOptions

    init(options: SandboxOptions = .current) {
        self.options = options
    }

    /// Transport chat-gateway untuk `TanyaAIBridge`. Host asli memanggil service ICT dengan header OMNI.
    @MainActor
    func makeChatTransport() -> TanyaAIChatTransport {
        SandboxChatTransport(options: options) { [callback] error in callback.onSubmissionFailed(error) }
    }

    /// Isi halaman sambutan dari fixture. Nil pada mode `--header-demo` (area scroll berisi konten contoh)
    /// atau bila fixture rusak, sehingga halaman tetap terbuka tanpa sambutan.
    func loadWelcome() -> WelcomeContent? {
        // TODO: Panggil inquiry init Tanya AI milik host setelah API tersedia.
        guard !options.isHeaderDemo, let url = SandboxFixtureFile.tanyaAIInitDummy.url,
            let data = try? Data(contentsOf: url)
        else { return nil }
        guard let response = try? JSONDecoder().decode(TanyaAIInitResponse.self, from: data) else { return nil }
        let welcome = response.data.welcome
        guard let iconURL = options.iconOverrideURL else { return welcome }
        return Self.replacingIcons(of: welcome, with: iconURL)
    }

    /// `--broken-icons`/`--slow-icons`: isi tetap dari fixture, hanya URL ikon yang diganti.
    private static func replacingIcons(of welcome: WelcomeContent, with iconURL: URL) -> WelcomeContent {
        let shortcuts = welcome.shortcuts.map {
            WelcomeShortcut(title: $0.title, description: $0.description, iconURL: iconURL, prompt: $0.prompt)
        }
        return WelcomeContent(greetings: welcome.greetings, shortcuts: shortcuts)
    }
}
