// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyLink",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "SwiftyLink",
            
            targets: ["SwiftyLink"]),
    ],
    dependencies: [
        .package(name: "swift-discord", url: "https://github.com/TotallyNotNero/Swift-Discord", .branch("master")),
    ],
    targets: [
        .target(
            name: "SwiftyLink",
            dependencies: [.product(name: "Discord", package: "swift-discord")]),
        .testTarget(
            name: "SwiftyLinkTests",
            dependencies: ["SwiftyLink"]),
    ]
)
