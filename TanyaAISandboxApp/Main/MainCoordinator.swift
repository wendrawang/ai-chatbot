//
//  MainCoordinator.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI

/// Tiruan main coordinator host. Tidak ada pendaftaran Tanya AI di sini; cukup penutupan saat logout.
@MainActor
struct MainCoordinator: View {
    @EnvironmentObject
    private var appState: AppState
    @State
    private var destinationCoordinatorName: String?
    @StateObject
    private var viewModel = MainScreenViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                DetailCoordinator(selectionCoordinatorName: $destinationCoordinatorName)
                Screen { MainScreen(viewModel: viewModel, onOpenDetail: openDetail) }
            }
        }
        .navigationViewStyle(.stack)
        .onChange(of: appState.state) { state in
            if state != .loggedIn { TanyaAIRouter.instance.close() }
        }
    }
}

// MARK: - Actions

private extension MainCoordinator {
    func openDetail() {
        destinationCoordinatorName = DetailCoordinator.named
    }
}
