//
//  FrameSample.swift
//  TanyaAISandboxTests
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI

/// Kotak setinggi 50 yang melaporkan frame global-nya saat tampil.
struct FrameSample: View {
    let onFrame: (CGRect) -> Void

    var body: some View {
        Color.clear.frame(height: 50)
            .background {
                GeometryReader { geometry in
                    Color.clear.onAppear { onFrame(geometry.frame(in: .global)) }
                }
            }
    }
}
