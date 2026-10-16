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
    dependencies: [.package(path: "../DesignKit")],
    targets: [
        .target(
            name: "TanyaAI", dependencies: [.product(name: "DesignKit", package: "DesignKit")],
            resources: [.process("Resources")]),
        .testTarget(name: "TanyaAITests", dependencies: ["TanyaAI", "DesignKit"])
    ]
)
