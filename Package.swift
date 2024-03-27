// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "APButton",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
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
            path: "APButton",
            exclude: [],
            sources: ["Classes"],
            resources: [
                .process("Privacy/PrivacyInfo.xcprivacy")
            ]
        ),
    ]
)
