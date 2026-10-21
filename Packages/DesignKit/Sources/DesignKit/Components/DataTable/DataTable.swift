//
//  DataTable.swift
//  DesignKit
//
//  Created by Wendra on 19/10/26.
//

import SwiftUI

/// Tabel ringkas (maks. tiga kolom dari data): kolom sama lebar di semua baris,
/// angka rata kanan, footer label membentang sampai kolom nilai terakhir.
@MainActor
public struct DataTable: View {
    @Environment(\.designColors)
    private var colors
    private let columns: [Column]
    private let rows: [[String]]
    private let footer: Footer?

    public struct Column: Equatable {
        public let title: String
        public let isTrailing: Bool

        public init(title: String, isTrailing: Bool = false) {
            self.title = title
            self.isTrailing = isTrailing
        }
    }

    public struct Footer: Equatable {
        public let label: String
        public let value: String

        public init(label: String, value: String) {
            self.label = label
            self.value = value
        }
    }

    public init(columns: [Column], rows: [[String]], footer: Footer? = nil) {
        self.columns = columns
        self.rows = rows
        self.footer = footer
    }

    public var body: some View {
        VStack(spacing: .zero) {
            row(columns.map(\.title), face: .firaSansSemiBold)
            ForEach(rows.indices, id: \.self) { index in
                divider
                row(rows[index], face: .firaSansRegular)
            }
            if let footer {
                divider
                footerRow(footer)
            }
            divider
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(ComponentIdentifier.Table.root)
    }

    private var divider: some View {
        colors.colorsOutlineNetral.frame(height: FigmaSize.weightOutline.scaledToArtwork)
    }

    private func row(_ cells: [String], face: FontFace) -> some View {
        HStack(alignment: .top, spacing: FigmaSize.spacingMedium.scaledToArtwork) {
            ForEach(columns.indices, id: \.self) { index in
                cell(cells.indices.contains(index) ? cells[index] : String(), face: face)
                    .multilineTextAlignment(columns[index].isTrailing ? .trailing : .leading)
                    .frame(maxWidth: .infinity, alignment: columns[index].isTrailing ? .trailing : .leading)
            }
        }
        .padding(.vertical, FigmaSize.spacingMedium.scaledToArtwork)
    }

    private func footerRow(_ footer: Footer) -> some View {
        HStack(spacing: FigmaSize.spacingMedium.scaledToArtwork) {
            cell(footer.label, face: .firaSansRegular).frame(maxWidth: .infinity, alignment: .leading)
            cell(footer.value, face: .firaSansSemiBold).fixedSize()
        }
        .padding(.vertical, FigmaSize.spacingMedium.scaledToArtwork)
    }

    private func cell(_ text: String, face: FontFace) -> some View {
        Text(text)
            .font(face.scaledFont(size: FigmaSize.typographySizeDisplaySmall14))
            .foregroundColor(colors.colorsTextPrimaryDark)
            .fixedSize(horizontal: false, vertical: true)
    }
}
