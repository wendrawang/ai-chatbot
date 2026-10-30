//
//  TanyaAIEntryUseCaseTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 30/10/26.
//

import Testing

@testable import Tanya_AI_Sandbox

/// Halaman induk: inquiry mengisi output lebih dulu, baru meminta coordinator membuka Tanya AI.
struct TanyaAIEntryUseCaseTests {
    @Test
    func inquiryFillsTheOutputBeforeStartingTanyaAI() {
        let useCase = TanyaAIEntryUseCase()
        var greetingAtStart: String?
        useCase.callback.onStartTanyaAI = { greetingAtStart = useCase.output.greeting.title }
        useCase.inquire()
        #expect(greetingAtStart == "Hi, Lara Croft!")
    }

    @Test
    func mainAndDetailOpenTanyaAIThroughTheirInquiry() {
        let main = MainScreenViewModel()
        let detail = DetailScreenViewModel()
        var starts = 0
        main.entryUseCase.callback.onStartTanyaAI = { starts += 1 }
        detail.entryUseCase.callback.onStartTanyaAI = { starts += 1 }
        main.openTanyaAI()
        detail.openTanyaAI()
        #expect(starts == 2)
        #expect(detail.entryUseCase.output.shortcuts.count == 3)
    }
}
