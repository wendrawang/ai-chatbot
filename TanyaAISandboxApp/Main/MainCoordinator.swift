//
//  MainCoordinator.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI

/// Tiruan main coordinator host. Link tujuan dibuat lazy: hanya tujuan yang sedang aktif yang dirender.
@MainActor
struct MainCoordinator: View {
    @State
    private var destinationCoordinatorName: String?
    @StateObject
    private var viewModel = MainScreenViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                navigationLink
                Screen {
                    MainScreen(
                        viewModel: viewModel,
                        onOpenDetail: { destinationCoordinatorName = DetailCoordinator.named },
                        onOpenTanyaAI: { destinationCoordinatorName = TanyaAICoordinator.named }
                    )
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private var navigationLink: some View {
        switch destinationCoordinatorName {
        case DetailCoordinator.named?:
            DetailCoordinator(selectionCoordinatorName: $destinationCoordinatorName)
        case TanyaAICoordinator.named?:
            TanyaAICoordinator(selectionCoordinatorName: $destinationCoordinatorName)
        default:
            EmptyView()
        }
    }
}
