// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Slab",
    platforms: [.iOS(.v17), .macOS(.v14), .tvOS(.v17)],
    products: [
        .library(name: "Slab", targets: ["Slab"])
    ],
    dependencies: [
        .package(url: "https://github.com/RNCryptor/RNCryptor.git", .upToNextMajor(from: "5.1.0"))
    ],
    targets: [
        .target(
            name: "Slab",
            dependencies: [
                .product(name: "RNCryptor", package: "RNCryptor")
            ],
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "SlabTests",
            dependencies: ["Slab"]
        ),
        
    ],
    swiftLanguageVersions: [.v5]
)
