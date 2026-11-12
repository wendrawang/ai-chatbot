//
//  BottomSheet.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

/// Permukaan bottom sheet: sudut atas membulat, grabber, lalu isi dari pemakai. Tinggi mengikuti isi; isi yang bisa
/// lebih tinggi dari layar men-scroll sendiri. Geser ke bawah menutup sheet. Posisi, latar gelap, dan animasi masuk
/// milik `BottomSheetPresenter`. `bottomInset` = safe area bawah, supaya isi tidak tertutup home indicator.
/// TODO: Cocokkan radius, grabber, dan jaraknya dengan Figma; sementara estimasi dari foto.
@MainActor
struct BottomSheet<Content: View>: View {
    @Environment(\.designColors) private var colors
    @Environment(\.accessibilityReduceMotion) private var isReducingMotion
    @GestureState private var dragDistance = CGFloat.zero
    private let closeLabel: String
    private let bottomInset: CGFloat
    private let onClose: () -> Void
    private let content: Content

    /// `closeLabel` = label aksesibilitas grabber, yang bagi VoiceOver menjadi tombol tutup.
    init(
        closeLabel: String,
        bottomInset: CGFloat,
        onClose: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.closeLabel = closeLabel
        self.bottomInset = bottomInset
        self.onClose = onClose
        self.content = content()
    }

    var body: some View {
        VStack(spacing: .zero) {
            handle
            content
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, bottomInset)
        .background(surface)
        .offset(y: dragDistance)
        .animation(releaseAnimation, value: dragDistance == .zero)
        .gesture(dismissDrag)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
        .accessibilityAction(.escape, onClose)
        .accessibilityIdentifier(ComponentIdentifier.BottomSheet.root)
    }

    private var handle: some View {
        Capsule()
            .fill(colors.colorsOutlineNetral)
            .frame(
                width: CustomSizes.BottomSheet.handleWidth.scaledToArtwork,
                height: CustomSizes.BottomSheet.handleHeight.scaledToArtwork
            )
            .padding(.top, FigmaSize.spacingMedium.scaledToArtwork)
            .padding(.bottom, FigmaSize.spacingLarge.scaledToArtwork)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .accessibilityElement()
            .accessibilityLabel(closeLabel)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction(.default, onClose)
            .accessibilityIdentifier(ComponentIdentifier.BottomSheet.handle)
    }

    /// Sudut bawah didorong ke luar layar, jadi hanya sudut atas yang tampak membulat.
    private var surface: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(colors.colorsSurfacePrimary)
            .padding(.bottom, -cornerRadius)
    }
}

// MARK: - Helpers

private extension BottomSheet {
    var cornerRadius: CGFloat { CustomSizes.BottomSheet.cornerRadius.scaledToArtwork }

    /// Sheet kembali ke tempatnya bila geseran dilepas sebelum jarak tutup.
    var releaseAnimation: Animation? {
        isReducingMotion ? nil : .easeOut(duration: CustomMotion.sheetSlide)
    }

    /// Mengikuti jari hanya ke bawah. Yang dihitung arah lepasnya (`predictedEndTranslation`), jadi sentakan pendek ke
    /// bawah juga menutup.
    var dismissDrag: some Gesture {
        DragGesture()
            .updating($dragDistance) { value, distance, _ in
                distance = max(.zero, value.translation.height)
            }
            .onEnded { value in
                let distance = CustomSizes.BottomSheet.dismissDistance.scaledToArtwork
                guard value.predictedEndTranslation.height > distance else { return }
                onClose()
            }
    }
}
