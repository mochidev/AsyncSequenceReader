//
//  AsyncIteratorProtocol+NonIsolated.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2026-05-01.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

extension AsyncIteratorProtocol {
    mutating func nonIsolatedNext() async rethrows -> Element? {
        nonisolated(unsafe) var iterator = self
        defer { self = iterator }
        return try await iterator.next()
    }
}
