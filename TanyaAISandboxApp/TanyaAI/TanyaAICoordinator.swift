//
//  TanyaAICoordinator.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 22/10/26.
//

import SwiftUI

/// Rute Tanya AI dengan pola coordinator host; tidak membuat view model.
@MainActor
struct TanyaAICoordinator: View {
    static let named = String(describing: TanyaAICoordinator.self)
    @Binding
    var selectionCoordinatorName: String?

    var body: some View {
        NavigationLink(tag: Self.named, selection: $selectionCoordinatorName) {
            TanyaAIDestination(onBack: close)
        } label: {
            EmptyView()
        }
        .hidden()
    }
}

// MARK: - Actions

private extension TanyaAICoordinator {
    func close() {
        guard selectionCoordinatorName == Self.named else { return }
        selectionCoordinatorName = nil
    }
}
