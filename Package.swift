// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "AnimalShogi",
    products: [
        .library(name: "AnimalShogi", targets: ["AnimalShogi"]),
        .executable(name: "asc", targets: ["AnimalShogiClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander", from: "0.8.0"),
        .package(url: "https://github.com/Nike-Inc/Willow", from: "5.1.0"),
        .package(url: "https://github.com/apple/swift-nio", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio-extras", from: "0.1.2"),
    ],
    targets: [
        .target(
            name: "AnimalShogi",
            dependencies: []
        ),
        .target(
            name: "AnimalShogiClient",
            dependencies: ["AnimalShogi", "NIO", "NIOExtras", "Commander", "Willow"]
        ),
        .testTarget(
            name: "AnimalShogiTests",
            dependencies: ["AnimalShogi"]
        ),
    ]
)
