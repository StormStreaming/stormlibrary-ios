// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StormLibrary",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        ],
    products: [
        .library(
            name: "StormLibrary",
            targets: ["StormLibrary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream", from: "4.0.4"),
    ],
    targets: [
        .target(
            name: "StormLibrary",
            dependencies: ["Starscream"]
        ),
        .testTarget(
            name: "StormLibraryTests",
            dependencies: ["StormLibrary"]),
    ]
)
