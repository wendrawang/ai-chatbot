//
//  TanyaAITermsTests.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 26/10/26.
//

import Foundation
import Testing

@testable import Tanya_AI_Sandbox

/// Gerbang T&C milik host: inquiry, simpan ke BE dan perangkat, lalu tidak tampil lagi.
@MainActor
struct TanyaAITermsTests {
    private let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: UUID().uuidString))
    }

    @Test
    func acceptingSavesToTheBackendAndTheDevice() async {
        let viewModel = TanyaAITermsViewModel(options: SandboxOptions(arguments: []), store: store)
        #expect(!viewModel.isAccepted)
        viewModel.load()
        await waitUntil { viewModel.phase != .loading }
        guard case .loaded(let terms) = viewModel.phase else {
            Issue.record("T&C harus termuat")
            return
        }
        #expect(!terms.paragraphs.isEmpty)
        viewModel.accept()
        await waitUntil { viewModel.isAccepted }
        let saved = await viewModel.useCase.service.acceptedVersions
        #expect(saved == [terms.version])
        #expect(store.isAccepted)
    }

    @Test
    func acceptedTermsAreNotLoadedAgain() async {
        store.accept()
        let viewModel = TanyaAITermsViewModel(options: SandboxOptions(arguments: []), store: store)
        #expect(viewModel.isAccepted)
        viewModel.load()
        #expect(viewModel.phase == .loading)
    }

    @Test
    func offlineInquiryShowsTheHostBlockerAndRetryLoadsAgain() async {
        let viewModel = TanyaAITermsViewModel(options: SandboxOptions(arguments: ["--offline"]), store: store)
        viewModel.load()
        await waitUntil { viewModel.phase == .failed }
        await waitUntil { viewModel.isNetworkUnavailable }
        #expect(!store.isAccepted)
        viewModel.retry()
        #expect(!viewModel.isNetworkUnavailable)
        // Inquiry diulang dan gagal lagi, jadi blocker host muncul kembali.
        await waitUntil { viewModel.isNetworkUnavailable }
    }
}

// MARK: - Helpers

private extension TanyaAITermsTests {
    var store: TanyaAITermsStore { TanyaAITermsStore(defaults: defaults) }
}
