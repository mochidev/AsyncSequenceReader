//
//  AnyReadableSequenceTests.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2026-04-29.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

@testable import AsyncSequenceReader
import Testing

@Suite struct AnyReadableSequenceTests {
    @Test func castSequence() async throws {
        let sequence = AnyReadableSequence([0, 1, 2])
        
        var iterator = sequence.makeAsyncIterator()
        
        #expect(await iterator.next() == 0)
        #expect(await iterator.next() == 1)
        #expect(await iterator.next() == 2)
        #expect(await iterator.next() == nil)
    }
    
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test func castAsyncSequence() async throws {
        let sequence = AnyReadableSequence(AsyncStream { continuation in
            continuation.yield(0)
            continuation.yield(1)
            continuation.yield(2)
            continuation.finish()
        })
        
        var iterator = sequence.makeAsyncIterator()
        
        #expect(await iterator.next() == 0)
        #expect(await iterator.next() == 1)
        #expect(await iterator.next() == 2)
        #expect(await iterator.next() == nil)
    }
    
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @Test func castThrowingAsyncSequence() async throws {
        let sequence = AnyReadableSequence(ThrowingTestSequence(base: [0, 1, 2]))
        
        var iterator = sequence.makeAsyncIterator()
        
        #expect(try await iterator.next() == 0)
        #expect(try await iterator.next() == 1)
        #expect(try await iterator.next() == 2)
        #expect(try await iterator.next() == nil)
    }
}
