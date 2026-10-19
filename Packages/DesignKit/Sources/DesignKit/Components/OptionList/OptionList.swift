//
//  OptionList.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import SwiftUI

/// Pilihan tunggal. Setelah dipilih atau saat tidak aktif menjadi riwayat read-only:
/// opsi terpilih bercentang hijau, opsi lain abu-abu.
@MainActor
public struct OptionList: View {
    @Environment(\.designColors)
    private var colors
    private let items: [Item]
    private let selectedID: String?
    private let isEnabled: Bool
    private let onSelect: (Item) -> Void

    public struct Item: Identifiable, Equatable {
        public let id: String
        public let label: String

        public init(id: String, label: String) {
            self.id = id
            self.label = label
        }
    }

    public init(items: [Item], selectedID: String?, isEnabled: Bool, onSelect: @escaping (Item) -> Void) {
        self.items = items
        self.selectedID = selectedID
        self.isEnabled = isEnabled
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(spacing: FigmaSize.spacingMedium.scaledToArtwork) {
            ForEach(items) { item in
                Button {
                    onSelect(item)
                } label: {
                    row(item)
                }
                .buttonStyle(.plain)
                .disabled(!isSelectable)
                .accessibilityAddTraits(item.id == selectedID ? .isSelected : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(ComponentIdentifier.Option.list)
    }

    private func row(_ item: Item) -> some View {
        HStack(spacing: CustomSizes.Option.indicatorGap.scaledToArtwork) {
            indicator(isSelected: item.id == selectedID)
            Text(item.label)
                .font(FontFace.firaSansRegular.scaledFont(size: FigmaSize.typographySizeDisplaySmall14))
                .foregroundColor(
                    isSelectable || item.id == selectedID ? colors.colorsTextPrimaryDark : colors.colorsTextDisabled
                )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(FigmaSize.spacingLarge.scaledToArtwork)
        .overlay(
            RoundedRectangle(cornerRadius: CustomSizes.Option.cornerRadius.scaledToArtwork)
                .strokeBorder(colors.colorsOutlineNetral, lineWidth: FigmaSize.weightOutline.scaledToArtwork)
        )
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func indicator(isSelected: Bool) -> some View {
        let size = FigmaSize.weightIconSmall.scaledToArtwork
        if isSelected {
            Image(R.image.checkmark).resizable().scaledToFit()
                .padding(FigmaSize.spacingSmall.scaledToArtwork)
                .foregroundColor(colors.colorsIconLight)
                .frame(width: size, height: size)
                .background(Circle().fill(colors.colorsIconSuccess))
        } else {
            Circle()
                .strokeBorder(
                    isSelectable ? colors.colorsIconDark : colors.colorsIconDisabled,
                    lineWidth: FigmaSize.weightOutline.scaledToArtwork
                )
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Helpers

private extension OptionList {
    var isSelectable: Bool { isEnabled && selectedID == nil }
}
