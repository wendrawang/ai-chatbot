//
//  RootScreen.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI

/// Tiruan root host: main tetap hidup selama prelogin tampil di atasnya, seperti host asli.
@MainActor
struct RootScreen: View {
    @ObservedObject
    var appState: AppState

    var body: some View {
        ZStack {
            MainCoordinator()
            if appState.state != .loggedIn {
                PreloginScreen()
            }
        }
        .environmentObject(appState)
    }
}
