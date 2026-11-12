//
//  ActionPage.swift
//  TanyaAITests
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

@testable import TanyaAI

/// Halaman dengan satu baris table; handler-nya membawa label `ActionModel` saat itu.
struct ActionPage: View {
    @ObservedObject var model: ActionModel
    /// Label milik handler yang terpanggil.
    let onCall: (String) -> Void
    /// Aksi yang diterima baris saat tampil.
    let onShow: (ChatRowActions) -> Void

    var body: some View {
        ChatTable(
            state: ChatTableState(items: ChatTableFixture.history(count: 1), historyPhase: .empty),
            headerHeight: .zero,
            actions: actions,
            onScrollProgress: { _ in },
            onLatestVisibilityChange: { _ in },
            row: { _, actions in ActionRow(actions: actions, onShow: onShow) }
        )
    }

    private var actions: ChatRowActions {
        ChatRowActions(
            onOpenLink: { [label = model.label, onCall] _ in onCall(label) },
            onSelectFollowUp: { [label = model.label, onCall] _ in onCall(label) }
        )
    }
}
