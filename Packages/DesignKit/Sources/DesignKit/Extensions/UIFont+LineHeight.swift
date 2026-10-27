//
//  UIFont+LineHeight.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import UIKit

public extension UIFont {
    /// Jarak tambahan antarbaris agar tinggi baris sama dengan token line-height Figma yang sudah di-scale,
    /// misalnya `typographyLineHeightDisplaySmall14` untuk `typographySizeDisplaySmall14`. Pakai dengan
    /// `.lineSpacing(_:)` pada `Text`. Nol bila line-height bawaan font sudah lebih tinggi.
    func lineSpacing(forLineHeight lineHeight: CGFloat) -> CGFloat {
        max(.zero, lineHeight - self.lineHeight)
    }
}
