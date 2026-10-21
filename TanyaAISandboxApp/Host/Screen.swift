//
//  Screen.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI

/// Tiruan base screen host. Membungkus setiap halaman agar blocker host berlaku, dan memasang
/// satu pintu masuk Tanya AI sehingga Tanya AI tidak perlu didaftarkan per coordinator.
@MainActor
struct Screen<Content: ScreenContent>: View {
    @ObservedObject
    private var contentViewModel: ScreenContentViewModel
    @ObservedObject
    private var tanyaAI = TanyaAIRouter.instance
    @State
    private var screenID = UUID()
    private let content: Content
    private let isTanyaAIAvailable: Bool

    /// `isTanyaAIAvailable: false` untuk halaman yang tidak boleh membuka Tanya AI, termasuk Tanya AI sendiri.
    init(isTanyaAIAvailable: Bool = true, _ content: () -> Content) {
        let content = content()
        self.content = content
        self.isTanyaAIAvailable = isTanyaAIAvailable
        contentViewModel = content.viewModel
    }

    var body: some View {
        ZStack {
            if isTanyaAIAvailable {
                tanyaAILink
            }
            content
            if contentViewModel.isNetworkUnavailable {
                NetworkUnavailableView(onRetry: contentViewModel.retry)
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: didAppear)
        .onDisappear(perform: didDisappear)
    }

    private var tanyaAILink: some View {
        NavigationLink(isActive: tanyaAI.isPresented(from: screenID)) {
            TanyaAIDestination(presenterID: screenID)
        } label: {
            EmptyView()
        }
    }
}

// MARK: - Actions

private extension Screen {
    func didAppear() {
        guard isTanyaAIAvailable else { return }
        tanyaAI.screenDidAppear(screenID)
    }

    func didDisappear() {
        guard isTanyaAIAvailable else { return }
        tanyaAI.screenDidDisappear(screenID)
    }
}
