// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeedPlot",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "FeedPlot",
            targets: ["FeedPlot"]),
    ],
    targets: [
        .target(
            name: "FeedPlot",
            dependencies: [],
            resources: [.process("Metal/FPShaders.metal")]
        ),
        .testTarget(
            name: "FeedPlotTests",
            dependencies: ["FeedPlot"]),
    ]
)
