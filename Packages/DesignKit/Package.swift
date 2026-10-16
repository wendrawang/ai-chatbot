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
    dependencies: [.package(url: "https://github.com/mac-cain13/R.swift.git", exact: "7.8.0")],
    targets: [
        .target(
            name: "DesignKit", dependencies: [.product(name: "RswiftLibrary", package: "R.swift")],
            resources: [.copy("Resources/Fonts"), .process("Resources/Assets.xcassets")],
            plugins: [.plugin(name: "RswiftGeneratePublicResources", package: "R.swift")]),
        .testTarget(name: "DesignKitTests", dependencies: ["DesignKit"])
    ]
)
