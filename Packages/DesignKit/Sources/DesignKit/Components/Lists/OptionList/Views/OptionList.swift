//
//  OptionList.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI

/// Isi bottom sheet untuk memilih: judul, lalu daftar pilihan. `items` nil = daftar masih diambil pemakai (mis. dari
/// service host), jadi spinner yang tampil. `.single`: satu ketukan langsung memanggil `onSelect`. `.multiple`: centang
/// sebanyak yang diperlukan lalu tombol `confirmLabel`. Tombol aktif bila ada centang yang masih ada di daftar;
/// `isEmptyAllowed` = pemakai boleh menerima hasil kosong (mengosongkan pilihan lama). `onSelect` menerima id pilihan
/// urut sesuai daftar; menutup sheet tetap tugas pemakai. Padding isi milik komponen ini, wadah sheet hanya memberi
/// permukaan.
/// TODO: Konfirmasi ukuran judul, baris, dan penanda dengan Figma; sementara dari foto.
@MainActor
public struct OptionList: View {
    @Environment(\.designColors) private var colors
    @State private var selection: OptionSelection
    private let title: String
    private let items: [OptionItem]?
    private let confirmLabel: String
    private let isEmptyAllowed: Bool
    private let onSelect: ([String]) -> Void

    public init(
        title: String,
        items: [OptionItem]?,
        selectedIDs: [String] = [],
        mode: OptionSelectionMode = .single,
        confirmLabel: String = String(),
        isEmptyAllowed: Bool = false,
        onSelect: @escaping ([String]) -> Void
    ) {
        _selection = State(initialValue: OptionSelection(mode: mode, selectedIDs: selectedIDs))
        self.title = title
        self.items = items
        self.confirmLabel = confirmLabel
        self.isEmptyAllowed = isEmptyAllowed
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            heading
            rows
            confirmButton
        }
        .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
        .padding(.bottom, FigmaSize.spacingLarge.scaledToArtwork)
    }

    private var heading: some View {
        Text(title)
            .font(FontFace.firaSansSemiBold.swiftUIFont(size: FigmaSize.typographySizeHeadingSmall20.scaledToArtwork))
            .foregroundColor(colors.colorsTextPrimaryDark)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, FigmaSize.spacingMedium.scaledToArtwork)
            .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private var rows: some View {
        if let items {
            ForEach(items) { item in
                OptionRow(item: item, mode: selection.mode, isSelected: selection.isSelected(item.id)) {
                    select(item.id, in: items)
                }
            }
        } else {
            LoadingIndicator()
                .frame(maxWidth: .infinity, minHeight: CustomSizes.OptionList.loadingHeight.scaledToArtwork)
        }
    }

    /// Hanya untuk pilihan banyak dan setelah daftar tersedia.
    @ViewBuilder
    private var confirmButton: some View {
        if selection.mode == .multiple, let items {
            let isConfirmable = selection.isConfirmable(in: items, isEmptyAllowed: isEmptyAllowed)
            FilledButton(title: confirmLabel, isEnabled: isConfirmable) {
                onSelect(selection.ordered(in: items))
            }
            .padding(.top, FigmaSize.spacingLarge.scaledToArtwork)
        }
    }
}

// MARK: - Actions

private extension OptionList {
    func select(_ id: String, in items: [OptionItem]) {
        guard selection.toggle(id) else { return }
        onSelect(selection.ordered(in: items))
    }
}
