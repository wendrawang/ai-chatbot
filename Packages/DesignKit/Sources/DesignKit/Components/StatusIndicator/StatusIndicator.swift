//
//  StatusIndicator.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import SwiftUI

/// Status proses ("processing the best answer for you…") dengan ikon sparkle berdenyut.
@MainActor
public struct StatusIndicator: View {
    @Environment(\.designColors)
    private var colors
    @Environment(\.accessibilityReduceMotion)
    private var isMotionReduced
    @State
    private var isDimmed = false
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        HStack(spacing: FigmaSize.spacingSmall.scaledToArtwork) {
            Image(R.image.sparkle).resizable().scaledToFit()
                .frame(width: CustomSizes.Status.icon.scaledToArtwork, height: CustomSizes.Status.icon.scaledToArtwork)
                .foregroundColor(colors.colorsIconColored)
                .opacity(isDimmed ? CustomMotion.StatusPulse.dimmedOpacity : CustomMotion.StatusPulse.fullOpacity)
            Text(text)
                .font(FontFace.firaSansRegular.scaledFont(size: FigmaSize.typographySizeDisplayTiny12))
                .foregroundColor(colors.colorsTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear(perform: startPulse)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(ComponentIdentifier.Status.indicator)
    }
}

// MARK: - Actions

private extension StatusIndicator {
    func startPulse() {
        guard !isMotionReduced else { return }
        withAnimation(.easeInOut(duration: CustomMotion.StatusPulse.duration).repeatForever()) { isDimmed = true }
    }
}
