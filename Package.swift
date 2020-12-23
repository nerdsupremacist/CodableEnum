// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CodableEnum",
    products: [
        .library(
            name: "CodableEnum",
            targets: ["CodableEnum"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wickwirew/Runtime.git", from: "2.2.2"),
    ],
    targets: [
        .target(
            name: "CodableEnum",
            dependencies: [
                .product(name: "Runtime", package: "Runtime"),
            ]),
        .testTarget(
            name: "CodableEnumTests",
            dependencies: ["CodableEnum"]),
    ]
)
