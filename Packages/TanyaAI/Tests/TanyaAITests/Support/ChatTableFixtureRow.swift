//
//  ChatTableFixtureRow.swift
//  TanyaAITests
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

@testable import TanyaAI

/// Tinggi berbeda-beda supaya perkiraan tinggi table tidak pernah kebetulan benar.
struct ChatTableFixtureRow: View {
    let item: ChatListItem

    var body: some View {
        Color.gray.frame(height: height)
    }

    private var height: CGFloat {
        if case .followUps = item { return .zero }
        guard case .message(let row, _) = item, let index = Int(row.id.dropFirst()) else { return 40 }
        return index.isMultiple(of: 2) ? 44 : CGFloat(200 + index % 7 * 40)
    }
}
