// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Slab",
    platforms: [.iOS(.v11), .macOS(.v10_15), .tvOS(.v14)],
    products: [
        .library(name: "Slab", targets: ["Slab"])
    ],
    targets: [
        .target(name: "Slab", dependencies: []),
        .testTarget(name: "SlabTests", dependencies: ["Slab"]),
    ],
    swiftLanguageVersions: [.v5]
)
