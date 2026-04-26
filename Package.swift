// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
//  Package.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-16.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

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
