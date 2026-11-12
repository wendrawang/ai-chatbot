//
//  ContentSample.swift
//  TanyaAITests
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

/// Konten sisipan contoh: melaporkan label setiap dirender dan tinggi yang benar-benar didapatnya.
struct ContentSample: View {
    let label: String
    let height: CGFloat
    let onRender: (String) -> Void
    let onResize: (CGFloat) -> Void

    var body: some View {
        onRender(label)
        return Color.clear.frame(height: height)
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .onAppear { onResize(geometry.size.height) }
                        .onChange(of: geometry.size.height) { onResize($0) }
                }
            }
    }
}
