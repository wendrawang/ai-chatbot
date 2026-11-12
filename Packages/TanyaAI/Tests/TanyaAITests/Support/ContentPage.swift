//
//  ContentPage.swift
//  TanyaAITests
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

@testable import TanyaAI

/// Halaman host yang menyisipkan `ContentSample` ke halaman Tanya AI dan mengikuti `ContentModel`.
struct ContentPage: View {
    let host: TanyaAIHost
    @ObservedObject var model: ContentModel
    let onRender: (String) -> Void
    let onResize: (CGFloat) -> Void

    var body: some View {
        host.makeView {
            if model.isVisible {
                ContentSample(label: model.label, height: model.height, onRender: onRender, onResize: onResize)
            }
        }
    }
}
