// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "TanyaAI",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "TanyaAI", targets: ["TanyaAI"]),
        .library(
            name: "TanyaAIDesignSystem",
            targets: ["TanyaAIDesignSystem"]
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
            name: "TanyaAIPresentation",
            dependencies: [
                "TanyaAIContracts",
                "TanyaAIDesignSystem",
                "TanyaAIDomain"
            ]
        ),
        .target(
            name: "TanyaAI",
            dependencies: [
                "TanyaAIContracts",
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
            name: "TanyaAIPresentationTests",
            dependencies: [
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
