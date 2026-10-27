//
//  DesignImage.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

/// Nama gambar di `Assets.xcassets` DesignKit. Nama case sama persis dengan nama imageset,
/// jadi menambah gambar cukup menambah case; `AssetTests` memastikan setiap case ada di bundle.
public enum DesignImage: String, CaseIterable {
    case backArrow
    case moreMenu
    case sendArrow
}
