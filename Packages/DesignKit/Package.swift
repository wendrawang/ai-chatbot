// swift-tools-version: 5.7

import PackageDescription

/// The design system, as a package of its own.
///
/// It knows nothing about Tanya AI: no session, no view model, no navigation.
/// The dependency runs one way - the feature package depends on this one - so
/// this can be lifted out and used by another feature without bringing a chat
/// along with it.
let package = Package(
    name: "DesignKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "DesignKit", targets: ["DesignKit"])
    ],
    targets: [
        .target(name: "DesignKit"),
        .testTarget(
            name: "DesignKitTests",
            dependencies: ["DesignKit"]
        )
    ]
)
