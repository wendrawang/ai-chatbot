//
//  ContentModel.swift
//  TanyaAITests
//
//  Created by Wendra on 12/11/26.
//

import Combine
import CoreGraphics

/// State host untuk konten sisipan di `ChatScreenContentTests`. Class karena `ObservableObject` mewajibkannya.
@MainActor
final class ContentModel: ObservableObject {
    static let shortHeight: CGFloat = 40
    static let tallHeight: CGFloat = 160
    @Published var label = "Before"
    @Published var height = ContentModel.shortHeight
    @Published var isVisible = true
}
