// swift-tools-version: 5.7
// Created by Wendra on 16/10/26.
import PackageDescription

let package = Package(
    name: "TanyaAI",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [.library(name: "TanyaAIFeature", targets: ["TanyaAIFeature"]),
               .library(name: "TanyaAIDomain", targets: ["TanyaAIDomain"])],
    dependencies: [.package(path: "../DesignKit"),
                   .package(url: "https://github.com/mac-cain13/R.swift.git", exact: "7.8.0")],
    targets: [
        .target(
            name: "TanyaAIDomain",
            exclude: [
                "Models/Action.swift",
                "Models/ResponseDocuments.swift",
                "Models/ResponsePayload+Interaction.swift",
                "Models/ResponsePayload.swift",
                "Models/ResponsePresentation.swift",
                "Models/ResponseSelection.swift",
                "Models/TanyaAIConnectionState.swift",
                "Models/TanyaAIMessage.swift",
                "Models/TanyaAIMessageContent.swift",
                "Models/TanyaAIStreamEvent.swift",
                "Repositories/TanyaAIRepository.swift",
            ]),
        .target(
            name: "TanyaAIFeature",
            dependencies: [
                "TanyaAIDomain",
                "DesignKit",
                .product(name: "RswiftLibrary", package: "R.swift"),
            ],
            resources: [.process("Resources")],
            plugins: [.plugin(
                name: "RswiftGenerateInternalResources",
                package: "R.swift")]),
        .testTarget(name: "TanyaAIFeatureTests", dependencies: ["TanyaAIFeature", "TanyaAIDomain"]),
    ])
