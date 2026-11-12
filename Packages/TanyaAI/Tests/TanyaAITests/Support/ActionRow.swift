//
//  ActionRow.swift
//  TanyaAITests
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

@testable import TanyaAI

/// Baris contoh yang melaporkan aksi yang diterimanya saat tampil.
struct ActionRow: View {
    let actions: ChatRowActions
    let onShow: (ChatRowActions) -> Void

    var body: some View {
        Color.clear.frame(height: 40)
            .onAppear { onShow(actions) }
    }
}
