// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: [PackageDescription.SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("ImmutableWeakCaptures"),
]

let package = Package(
    name: "AsyncSequenceReader",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "AsyncSequenceReader",
            targets: ["AsyncSequenceReader"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AsyncSequenceReader",
            dependencies: [],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AsyncSequenceReaderTests",
            dependencies: ["AsyncSequenceReader"],
            swiftSettings: swiftSettings
        ),
    ]
)
