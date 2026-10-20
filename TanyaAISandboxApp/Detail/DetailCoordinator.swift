//
//  DetailCoordinator.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI

/// Tiruan coordinator halaman lain, memakai pola NavigationLink + tag milik host.
@MainActor
struct DetailCoordinator: View {
    static let named = String(describing: DetailCoordinator.self)
    @Binding
    var selectionCoordinatorName: String?
    @StateObject
    private var viewModel = DetailScreenViewModel()

    var body: some View {
        NavigationLink(
            destination: Screen { DetailScreen(viewModel: viewModel) },
            tag: Self.named,
            selection: $selectionCoordinatorName
        ) {
            EmptyView()
        }
        .hidden()
    }
}
