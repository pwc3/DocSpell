// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DocSpell",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.0.6")),
        .package(url: "https://github.com/jpsim/SourceKitten", .upToNextMinor(from: "0.29.0")),
    ],
    targets: [
        .target(
            name: "DocSpell",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
            ]),
        .testTarget(
            name: "DocSpellTests",
            dependencies: ["DocSpell"]),
    ]
)
