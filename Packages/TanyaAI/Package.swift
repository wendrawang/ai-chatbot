// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "TanyaAI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "TanyaAI", targets: ["TanyaAI"]),
        .library(
            name: "TanyaAITestSupport",
            targets: ["TanyaAITestSupport"]
        )
    ],
    dependencies: [
        // The design system is its own package, so it can be lifted out for
        // another feature. The dependency only ever runs this way.
        .package(path: "../DesignKit")
    ],
    targets: [
        .target(name: "TanyaAIContracts"),
        .target(
            name: "TanyaAIDomain",
            dependencies: [
                "TanyaAIContracts",
                .product(name: "DesignKit", package: "DesignKit")
            ]
        ),
        .target(
            name: "TanyaAIData",
            dependencies: [
                "TanyaAIContracts",
                "TanyaAIDomain"
            ]
        ),
        .target(
            name: "TanyaAIPresentation",
            dependencies: [
                "TanyaAIContracts",
                "TanyaAIDomain",
                .product(name: "DesignKit", package: "DesignKit")
            ]
        ),
        .target(
            name: "TanyaAI",
            dependencies: [
                "TanyaAIContracts",
                "TanyaAIDomain",
                "TanyaAIData",
                "TanyaAIPresentation",
                .product(name: "DesignKit", package: "DesignKit")
            ]
        ),
        .target(
            name: "TanyaAITestSupport",
            dependencies: ["TanyaAIContracts"]
        ),
        .testTarget(
            name: "TanyaAIDataTests",
            dependencies: [
                "TanyaAIData",
                "TanyaAIDomain",
                "TanyaAITestSupport"
            ]
        ),
        .testTarget(
            name: "TanyaAIDomainTests",
            dependencies: [
                "TanyaAIDomain",
                "TanyaAITestSupport"
            ]
        ),
        .testTarget(
            name: "TanyaAIPresentationTests",
            dependencies: [
                "TanyaAIPresentation",
                "TanyaAIDomain",
                "TanyaAITestSupport",
                .product(name: "DesignKit", package: "DesignKit")
            ]
        ),
        .testTarget(
            name: "TanyaAINavigationTests",
            dependencies: [
                "TanyaAI",
                "TanyaAITestSupport"
            ]
        ),
        .testTarget(
            name: "TanyaAIPerformanceTests",
            dependencies: [
                "TanyaAI",
                "TanyaAIContracts",
                "TanyaAIData",
                "TanyaAIDomain",
                "TanyaAIPresentation",
                "TanyaAITestSupport"
            ]
        )
    ]
)
