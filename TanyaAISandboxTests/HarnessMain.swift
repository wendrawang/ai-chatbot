//
//  HarnessMain.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI

@testable import Tanya_AI_Sandbox

/// Sama dengan `MainCoordinator`, tetapi tujuan dikendalikan test.
struct HarnessMain: View {
    @ObservedObject
    var probe: DestinationProbe
    @StateObject
    private var viewModel = MainScreenViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                if probe.destination == TanyaAICoordinator.named {
                    TanyaAICoordinator(selectionCoordinatorName: $probe.destination)
                }
                Screen { MainScreen(viewModel: viewModel, onOpenDetail: {}, onOpenTanyaAI: {}) }
                Text(String(probe.tick))
            }
        }
        .navigationViewStyle(.stack)
    }
}
