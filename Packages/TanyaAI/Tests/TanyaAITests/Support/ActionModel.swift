//
//  ActionModel.swift
//  TanyaAITests
//
//  Created by Wendra on 12/11/26.
//

import Combine

/// State host yang mengganti handler baris di `ChatTableActionsTests`. Class karena `ObservableObject` mewajibkannya.
@MainActor
final class ActionModel: ObservableObject {
    @Published var label = "Before"
}
