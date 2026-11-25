//
//  ActionBanner.swift
//  DesignKit
//
//  Created by Wendra on 19/11/26.
//

import SwiftUI

/// Bar status selebar layar, mis. di bawah header: teks di kiri dan, bila ada, tombol kecil merah di kanan. Teks
/// panjang turun ke baris berikutnya, tombol tetap seukuran judulnya. Copy dan aksi dari pemakai; nonaktif lewat
/// `.disabled(...)`. Tanpa tombol, bar hanya memberi tahu (snackbar).
/// TODO: Konfirmasi warna, ukuran teks, dan jarak dengan Figma; sementara dari foto. Nada `.warning` memakai token
/// oranye `colorsIconOngoing` karena belum ada token permukaan oranye.
@MainActor
public struct ActionBanner: View {
    @Environment(\.designColors) private var colors
    @Environment(\.isEnabled) private var isEnabled
    private let text: String
    private let tone: ActionBannerTone
    private let actionTitle: String?
    private let onAction: () -> Void

    public init(text: String, tone: ActionBannerTone = .neutral, actionTitle: String, onAction: @escaping () -> Void) {
        self.text = text
        self.tone = tone
        self.actionTitle = actionTitle
        self.onAction = onAction
    }

    /// Bar pemberitahuan tanpa tombol.
    public init(text: String, tone: ActionBannerTone = .neutral) {
        self.text = text
        self.tone = tone
        self.actionTitle = nil
        self.onAction = {}
    }

    public var body: some View {
        HStack(spacing: FigmaSize.spacingMedium.scaledToArtwork) {
            Text(text)
                .designFont(.caption)
                .foregroundColor(textColor)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            actionButton
        }
        .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
        .padding(.vertical, FigmaSize.spacingMedium.scaledToArtwork)
        .background(fillColor)
    }

    @ViewBuilder
    private var actionButton: some View {
        if let actionTitle {
            Button(action: onAction) {
                Text(actionTitle)
                    .designFont(.captionStrong)
                    .foregroundColor(colors.colorsTextPrimaryLight)
                    .padding(.horizontal, FigmaSize.spacingMedium.scaledToArtwork)
                    .padding(.vertical, FigmaSize.spacingSmall.scaledToArtwork)
                    .cardStyle(isOutlined: false, isElevated: false, fillColor: buttonColor)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .fixedSize()
        }
    }
}

// MARK: - Helpers

private extension ActionBanner {
    var buttonColor: Color {
        isEnabled ? colors.colorsButtonActive : colors.colorsIconDisabled
    }

    var fillColor: Color {
        switch tone {
        case .neutral: return colors.colorsSurfaceOverlay24
        case .warning: return colors.colorsIconOngoing
        }
    }

    var textColor: Color {
        switch tone {
        case .neutral: return colors.colorsTextPrimaryLight
        case .warning: return colors.colorsTextPrimaryDark
        }
    }
}
