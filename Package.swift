// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "APButton",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
    ],
    products: [
        .library(
            name: "APButton",
            targets: ["APButton"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "APButton",
            dependencies: [],
            path: "APButton/Classes",
            exclude: []),
    ]
)
