//
//  RenderedImage.swift
//  DesignKitTests
//
//  Created by Wendra on 12/11/26.
//

import SwiftUI
import UIKit

/// Hasil gambar sebuah view untuk membandingkan tampilan dua keadaan. `ImageRenderer` baru ada di iOS 16, jadi di
/// bawahnya hasilnya nil dan test yang memakainya berhenti di `#require`.
@MainActor
enum RenderedImage {
    static func png(of content: some View, width: CGFloat) -> Data? {
        guard #available(iOS 16, *) else { return nil }
        let renderer = ImageRenderer(content: content.frame(width: width))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage?.pngData()
    }
}
