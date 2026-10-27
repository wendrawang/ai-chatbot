//
//  Image+DesignImage.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import SwiftUI

public extension Image {
    /// Gambar DesignKit dari bundle package, bukan bundle host.
    init(_ image: DesignImage) {
        self.init(image.rawValue, bundle: .module)
    }
}

public extension UIImage {
    /// Versi UIKit dari `Image(_:)`; nil bila imageset tidak ada di bundle.
    convenience init?(_ image: DesignImage) {
        self.init(named: image.rawValue, in: .module, with: nil)
    }
}
