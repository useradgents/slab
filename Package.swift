// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Slab",
    platforms: [.iOS(.v11), .macOS(.v10_15)],
    products: [
        .library(name: "Slab", targets: ["Slab"])
    ],
    dependencies: [
        .package(name: "RNCryptor", url: "https://github.com/RNCryptor/RNCryptor.git", .branch("release")),
        .package(name: "KeychainSwift", url: "https://github.com/evgenyneu/keychain-swift.git", .branch("master")),
        .package(name: "Reachability", url: "https://github.com/ashleymills/Reachability.swift.git", .branch("master"))
    ],
    targets: [
        .target(name: "Slab", dependencies: ["RNCryptor", "KeychainSwift", "Reachability"]),
        .testTarget(name: "SlabTests", dependencies: ["Slab"]),
    ],
    swiftLanguageVersions: [.v5]
)
