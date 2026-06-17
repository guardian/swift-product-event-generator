// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-product-event-generator",
    platforms: [
        .iOS(.v18), .macOS(.v11)
    ],
    products: [
        .library(
            name: "ProductEventModels",
            targets: ["ProductEventModels"]
        ),
        .executable(name: "swift-product-event-generator", targets: ["swift-product-event-generator"])
    ],
    dependencies: [
          .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
          .package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.0")
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ProductEventModels"
        ),
        .executableTarget(
            name: "swift-product-event-generator",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ],
            path: "Sources/swift-product-event-generator"),
    ]
)
