//
//  TanyaAIUseCaseTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 30/10/26.
//

import Foundation
import TanyaAI
import Testing

@testable import Tanya_AI_Sandbox

/// Input (dari coordinator) diolah `loadWelcome` ke repository (dibaca view model).
struct TanyaAIUseCaseTests {
    @Test
    func welcomeComesFromTheInputInBackendOrder() throws {
        let welcome = try #require(loadWelcome().repository.welcome)
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
        let welcome = try #require(loadWelcome(arguments: ["--broken-icons"]).repository.welcome)
        #expect(welcome.shortcuts.count == 3)
        #expect(welcome.shortcuts.allSatisfy { $0.iconURL == SandboxOptions.brokenIconURL })
        #expect(welcome.shortcuts.first?.prompt == "Cek Portfolio saya")
    }

    @Test
    func slowIconsModePointsIconsAtAnAddressThatNeverAnswers() throws {
        let welcome = try #require(loadWelcome(arguments: ["--slow-icons"]).repository.welcome)
        #expect(welcome.shortcuts.allSatisfy { $0.iconURL == SandboxOptions.slowIconURL })
        #expect(loadWelcome().repository.welcome?.shortcuts.first?.iconURL != SandboxOptions.slowIconURL)
    }

    @Test
    func headerDemoShowsItsSampleContentInsteadOfTheWelcome() {
        #expect(loadWelcome(arguments: ["--header-demo"]).repository.welcome == nil)
    }

    @Test
    func missingInputOpensThePageWithoutAWelcome() {
        let useCase = TanyaAIUseCase(options: SandboxOptions(arguments: []))
        useCase.loadWelcome()
        #expect(useCase.repository.welcome == nil)
    }

    /// Sapaan kosong tidak dikirim sebagai sambutan berisi teks kosong walau shortcut ada.
    @Test
    func emptyGreetingOpensThePageWithoutAWelcome() {
        let useCase = TanyaAIUseCase(options: SandboxOptions(arguments: []))
        useCase.input.shortcuts = [
            TanyaAIInitShortcut(title: "Portfolio", description: "Cek", iconUrl: nil, prompt: "Cek Portfolio saya")
        ]
        useCase.loadWelcome()
        #expect(useCase.repository.welcome == nil)
    }
}

// MARK: - Helpers

private extension TanyaAIUseCaseTests {
    func loadWelcome(arguments: [String] = []) -> TanyaAIUseCase {
        let entry = TanyaAIEntryUseCase()
        entry.inquire()
        let useCase = TanyaAIUseCase(options: SandboxOptions(arguments: arguments))
        useCase.input.greeting = entry.output.greeting
        useCase.input.shortcuts = entry.output.shortcuts
        useCase.loadWelcome()
        return useCase
    }
}
