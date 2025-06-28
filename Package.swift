// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "isdb-view",
    products: [
        .executable(name: "isdb-view", targets: ["isdb-view"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/indexstore-db.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.1"),
    ],
    targets: [
        .executableTarget(
            name: "isdb-view",
            dependencies: [
                .product(name: "IndexStoreDB", package: "indexstore-db"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        )
    ]
)
