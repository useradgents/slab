// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Slab",
    platforms: [.iOS(.v11), .macOS(.v10_15)],
    products: [
        .library(name: "Slab", targets: ["Slab"])
    ],
    dependencies: [
        .package(name: "RNCryptor", url: "https://github.com/RNCryptor/RNCryptor.git", from: "5.1.0")
    ],
    targets: [
        .target(name: "Slab", dependencies: ["RNCryptor"]),
        .testTarget(name: "SlabTests", dependencies: ["Slab"]),
    ],
    swiftLanguageVersions: [.v5]
)
