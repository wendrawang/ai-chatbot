//
//  View+DesignFont.swift
//  DesignKit
//
//  Created by Wendra on 18/10/26.
//

import SwiftUI

public extension View {
    /// Pasang font dan line height Figma sekaligus: `Text(title).designFont(.screenTitle)`.
    func designFont(_ style: DesignTextStyle) -> some View {
        font(style.font).lineSpacing(style.lineSpacing)
    }
}
