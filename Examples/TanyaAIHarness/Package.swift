// swift-tools-version: 5.7
// Created by Wendra on 16/10/26.
import PackageDescription

let package = Package(
    name: "TanyaAIHarness",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [.library(name: "TanyaAIHarnessSupport", targets: ["TanyaAIHarnessSupport"])],
    dependencies: [
        .package(path: "../../Packages/TanyaAI"),
        .package(path: "../../Packages/DesignKit"),
        .package(url: "https://github.com/mac-cain13/R.swift.git", exact: "7.8.0"),
    ],
    targets: [.target(
        name: "TanyaAIHarnessSupport",
        dependencies: [
            .product(name: "TanyaAIFeature", package: "TanyaAI"), .product(
                name: "TanyaAIDomain",
                package: "TanyaAI"),
            .product(name: "DesignKit", package: "DesignKit"), .product(
                name: "RswiftLibrary",
                package: "R.swift"),
        ],
        resources: [.process("Resources")],
        plugins: [.plugin(
            name: "RswiftGenerateInternalResources",
            package: "R.swift")])])
