//
//  DesignTextStyle+Roles.swift
//  DesignKit
//
//  Created by Wendra on 18/10/26.
//

/// Preset per peran teks. Tambahkan peran baru di sini saat ada pemakainya,
/// memakai token tipografi Figma bernama (bukan `typographySize14` polos).
public extension DesignTextStyle {
    /// Judul halaman pada header: Fira Sans SemiBold, Display Normal 16/24.
    static let screenTitle = DesignTextStyle(
        face: .firaSansSemiBold, size: FigmaSize.typographySizeDisplayNormal16,
        lineHeight: FigmaSize.typographyLineHeightDisplayNormal16
    )

    /// Teks isi dan input: Open Sans Regular, Display Small 14/21.
    static let body = DesignTextStyle(
        face: .openSansRegular, size: FigmaSize.typographySizeDisplaySmall14,
        lineHeight: FigmaSize.typographyLineHeightDisplaySmall14
    )
}
