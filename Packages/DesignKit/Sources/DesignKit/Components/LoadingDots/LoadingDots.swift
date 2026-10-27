//
//  LoadingDots.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import SwiftUI

/// Titik yang naik-turun bergantian sebagai tanda menunggu. Warna dari caller; ukuran dan waktu dari token.
/// Dengan Reduce Motion, titik diam agar tetap terbaca tanpa gerakan.
@MainActor
public struct LoadingDots: View {
    @Environment(\.accessibilityReduceMotion)
    private var isReduceMotion
    @State
    private var isRaised = false
    private let color: Color

    public init(color: Color) {
        self.color = color
    }

    public var body: some View {
        HStack(spacing: CustomSizes.LoadingDots.gap.scaledToArtwork) {
            ForEach(Int.zero..<CustomMotion.LoadingDots.dotCount, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: dotSize, height: dotSize)
                    .offset(y: isRaised ? -CustomSizes.LoadingDots.bounce.scaledToArtwork : .zero)
                    .animation(bounce(at: index), value: isRaised)
            }
        }
        .onAppear { isRaised = !isReduceMotion }
        .onChange(of: isReduceMotion) { isRaised = !$0 }
        .accessibilityHidden(true)
    }
}

// MARK: - Helpers

private extension LoadingDots {
    var dotSize: CGFloat { CustomSizes.LoadingDots.dot.scaledToArtwork }

    /// Setiap titik mulai sedikit lebih lambat dari titik sebelumnya sehingga terlihat bergelombang.
    func bounce(at index: Int) -> Animation? {
        guard !isReduceMotion else { return nil }
        return Animation.easeInOut(duration: CustomMotion.LoadingDots.bounceDuration)
            .repeatForever(autoreverses: true)
            .delay(CustomMotion.LoadingDots.stagger * Double(index))
    }
}
