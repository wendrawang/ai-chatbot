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
    platforms: [.iOS(.v15)],
    products: [.library(name: "DesignKit", targets: ["DesignKit"])],
    targets: [
        .target(name: "DesignKit", resources: [.copy("Resources/Fonts")]),
        .testTarget(name: "DesignKitTests", dependencies: ["DesignKit"])
    ]
)
