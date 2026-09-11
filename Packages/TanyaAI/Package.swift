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
            name: "TanyaAIDesignSystem",
            targets: ["TanyaAIDesignSystem"]
        ),
        // The bubbles themselves, so a revamp continues from them rather
        // than starting over. Its API is built on the payload types, which
        // is why TanyaAIDomain is a product alongside it.
        .library(
            name: "TanyaAIDesignKit",
            targets: ["TanyaAIDesignKit"]
        ),
        .library(
            name: "TanyaAIDomain",
            targets: ["TanyaAIDomain"]
        ),
        .library(
            name: "TanyaAITestSupport",
            targets: ["TanyaAITestSupport"]
        )
    ],
    targets: [
        .target(name: "TanyaAIContracts"),
        .target(name: "TanyaAIDesignSystem"),
        .target(
            name: "TanyaAIDomain",
            dependencies: ["TanyaAIContracts"]
        ),
        .target(
            name: "TanyaAIData",
            dependencies: [
                "TanyaAIContracts",
                "TanyaAIDomain"
            ]
        ),
        .target(
            name: "TanyaAIDesignKit",
            dependencies: [
                "TanyaAIDesignSystem",
                "TanyaAIDomain"
            ]
        ),
        .target(
            name: "TanyaAIPresentation",
            dependencies: [
                "TanyaAIContracts",
                "TanyaAIDesignKit",
                "TanyaAIDesignSystem",
                "TanyaAIDomain"
            ]
        ),
        .target(
            name: "TanyaAI",
            dependencies: [
                "TanyaAIContracts",
                "TanyaAIDesignKit",
                "TanyaAIDesignSystem",
                "TanyaAIDomain",
                "TanyaAIData",
                "TanyaAIPresentation"
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
            name: "TanyaAIDesignKitTests",
            dependencies: [
                "TanyaAIDesignKit",
                "TanyaAIDomain"
            ]
        ),
        .testTarget(
            name: "TanyaAIPresentationTests",
            dependencies: [
                "TanyaAIDesignKit",
                "TanyaAIPresentation",
                "TanyaAIDomain",
                "TanyaAITestSupport"
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
