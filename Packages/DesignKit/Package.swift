// swift-tools-version: 5.7
//
//  Package.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import PackageDescription

let package = Package(
    name: "DesignKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [.library(name: "DesignKit", targets: ["DesignKit"])],
    // Kingfisher hanya dipakai `RemoteImage`; 8.14 butuh Xcode 26 (swift-tools 6.2).
    // Versi dikunci `exact` agar semua anggota tim sama; naik versi hanya lewat perubahan baris ini.
    dependencies: [.package(url: "https://github.com/onevcat/Kingfisher.git", exact: "8.14.0")],
    targets: [
        .target(
            name: "DesignKit",
            dependencies: [.product(name: "Kingfisher", package: "Kingfisher")],
            resources: [.copy("Resources/Fonts"), .process("Resources/Assets.xcassets")]),
        .testTarget(name: "DesignKitTests", dependencies: ["DesignKit"])
    ]
)
