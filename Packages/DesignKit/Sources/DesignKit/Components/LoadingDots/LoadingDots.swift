//
//  LoadingDots.swift
//  DesignKit
//
//  Created by Wendra on 26/10/26.
//

import SwiftUI

/// Tiga titik yang melompat bergantian, penanda proses yang sedang berjalan.
/// Diam saat Reduce Motion aktif. Warna dari pemakai agar bisa dipakai di atas latar apa pun.
@MainActor
public struct LoadingDots: View {
    @Environment(\.accessibilityReduceMotion)
    private var isReduceMotion
    private let color: Color

    public init(color: Color) {
        self.color = color
    }

    public var body: some View {
        TimelineView(.animation(minimumInterval: nil, paused: isReduceMotion)) { timeline in
            HStack(spacing: CustomSizes.LoadingDots.spacing.scaledToArtwork) {
                ForEach(Array(.zero..<CustomMotion.LoadingDots.count), id: \.self) { index in
                    Circle()
                        .fill(color)
                        .frame(width: dotSize, height: dotSize)
                        .offset(y: isReduceMotion ? .zero : offset(of: index, at: timeline.date))
                }
            }
            // Ruang lompatan ikut dihitung agar ukuran view tidak berubah selama animasi.
            .padding(.vertical, CustomSizes.LoadingDots.bounce.scaledToArtwork)
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Helpers

private extension LoadingDots {
    var dotSize: CGFloat { CustomSizes.LoadingDots.dot.scaledToArtwork }

    /// Gelombang sinus yang hanya bergerak ke atas, digeser per titik.
    func offset(of index: Int, at date: Date) -> CGFloat {
        let delay = Double(index) * CustomMotion.LoadingDots.stagger
        let elapsed = date.timeIntervalSinceReferenceDate - delay
        let progress =
            elapsed.truncatingRemainder(dividingBy: CustomMotion.LoadingDots.period)
            / CustomMotion.LoadingDots.period
        let lift = max(.zero, sin(progress * CustomMotion.LoadingDots.fullTurn))
        return -CGFloat(lift) * CustomSizes.LoadingDots.bounce.scaledToArtwork
    }
}
