//
//  TanyaAIScreenViewModelTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 27/10/26.
//

import TanyaAI
import Testing

@testable import Tanya_AI_Sandbox

/// Host tiruan: isi sambutan dari fixture inquiry init; bridge dibuat sekali bersama transport host.
struct TanyaAIScreenViewModelTests {
    @Test
    func welcomeComesFromTheInitFixtureInBackendOrder() throws {
        let viewModel = makeViewModel()
        let welcome = try #require(viewModel.welcome)
        #expect(welcome.greetings.title == "Hi, Lara Croft!")
        #expect(
            welcome.shortcuts.map(\.prompt) == [
                "Cek Portfolio saya", "Saya mau beli valas", "Ajukan bank reference letter"
            ]
        )
        #expect(welcome.shortcuts.allSatisfy { $0.iconURL != nil })
    }

    @Test
    func brokenIconsModeKeepsEveryShortcutButPointsIconsAtAMissingFile() throws {
        let welcome = try #require(makeViewModel(arguments: ["--broken-icons"]).welcome)
        #expect(welcome.shortcuts.count == 3)
        #expect(welcome.shortcuts.allSatisfy { $0.iconURL == SandboxOptions.brokenIconURL })
        #expect(welcome.shortcuts.first?.prompt == "Cek Portfolio saya")
    }

    @Test
    func slowIconsModePointsIconsAtAnAddressThatNeverAnswers() throws {
        let welcome = try #require(makeViewModel(arguments: ["--slow-icons"]).welcome)
        #expect(welcome.shortcuts.allSatisfy { $0.iconURL == SandboxOptions.slowIconURL })
        #expect(makeViewModel().welcome?.shortcuts.first?.iconURL != SandboxOptions.slowIconURL)
    }

    @Test
    func headerDemoShowsItsSampleContentInsteadOfTheWelcome() {
        #expect(makeViewModel(arguments: ["--header-demo"]).welcome == nil)
    }

    /// Bridge memegang callback dan transport host secara weak: view model tetap dilepas walau bridge masih hidup.
    @MainActor
    @Test
    func bridgeDoesNotKeepTheViewModelAlive() {
        weak var releasedViewModel: TanyaAIScreenViewModel?
        var bridge: TanyaAIBridge?
        do {
            let viewModel = makeViewModel()
            releasedViewModel = viewModel
            bridge = viewModel.bridge
        }
        #expect(bridge != nil)
        #expect(releasedViewModel == nil)
    }
}

// MARK: - Helpers

private extension TanyaAIScreenViewModelTests {
    func makeViewModel(arguments: [String] = []) -> TanyaAIScreenViewModel {
        TanyaAIScreenViewModel(useCase: TanyaAIUseCase(options: SandboxOptions(arguments: arguments)))
    }
}
