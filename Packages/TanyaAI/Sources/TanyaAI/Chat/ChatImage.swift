//
//  ChatImage.swift
//  TanyaAI
//
//  Created by Wendra on 27/10/26.
//

import SwiftUI

/// Gambar non-ikon milik Tanya AI di `Assets.xcassets` package. Nama case sama dengan nama imageset;
/// `AssetTests` memastikan keduanya sinkron.
/// TODO: Ganti placeholder dengan aset final dari desain; nama imageset tetap.
enum ChatImage: String, CaseIterable {
    case chatBackground
    case welcomeOrb
}

extension Image {
    /// Gambar Tanya AI dari bundle package, bukan bundle host.
    init(_ image: ChatImage) { self.init(image.rawValue, bundle: .module) }
}
