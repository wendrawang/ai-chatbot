// swift-tools-version: 5.7
//
//  Package.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import PackageDescription

let package = Package(
    name: "TanyaAI",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [.library(name: "TanyaAI", targets: ["TanyaAI"])],
    dependencies: [
        .package(path: "../DesignKit"),
        .package(url: "https://github.com/mac-cain13/R.swift.git", from: "7.8.0")
    ],
    targets: [
        .target(
            name: "TanyaAI",
            dependencies: [
                .product(name: "DesignKit", package: "DesignKit"),
                .product(name: "RswiftLibrary", package: "R.swift")
            ],
            resources: [.process("Resources")]),
        .testTarget(name: "TanyaAITests", dependencies: ["TanyaAI", "DesignKit"])
    ]
)
