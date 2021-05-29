// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Tools",
    products: [
        .library(
            name: "Tools",
            targets: ["Tools", "Utils", "Framework"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.0"),
        .package(url: "https://github.com/kiliankoe/CLISpinner", from: "0.4.0")
    ],
    targets: [
        .target(
            name: "Tools",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .target(
            name: "Utils",
            dependencies: [
                .product(name: "CLISpinner", package: "CLISpinner")
            ]),
        .target(
            name: "Framework",
            dependencies: []),
        .target(
            name: "XCBuild",
            dependencies: [])
    ]
)
