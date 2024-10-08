//
//  AsyncBufferedIteratorTests.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-16.
//  Copyright © 2021 Mochi Development, Inc. All rights reserved.
//

import XCTest
@testable import AsyncSequenceReader

final class AsyncBufferedIteratorTests: XCTestCase, @unchecked Sendable {
    func testBufferIteratorFromStream() async throws {
        let testStream = AsyncStream<Int> { continuation in
            for value in 0..<10 {
                continuation.yield(value)
            }
            continuation.finish()
        }
        
        var iterator = testStream.makeAsyncIterator()
        
        await AsyncXCTAssertEqual(await iterator.next(), 0)
        await AsyncXCTAssertEqual(await iterator.next(), 1)
        
        iterator = testStream.makeAsyncIterator()
        
        await AsyncXCTAssertEqual(await iterator.next(), 2)
        await AsyncXCTAssertEqual(await iterator.next(), 3)
        
        var bufferedIterator = AsyncBufferedIterator(iterator)
        
        await AsyncXCTAssertEqual(await bufferedIterator.next(), 4)
        await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), true)
        await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), true)
        await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), true)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), 5)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), 6)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), 7)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), 8)
        await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), true)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), 9)
        await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), false)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), nil)
        await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), false)
        await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), false)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), nil)
    }
    
    func testBufferIteratorFromTestSequence() async throws {
        let testStream = TestSequence(base: 0..<10)
        
        var iterator = testStream.makeAsyncIterator()
        
        await AsyncXCTAssertEqual(await iterator.next(), 0)
        await AsyncXCTAssertEqual(await iterator.next(), 1)
        
        iterator = testStream.makeAsyncIterator()
        
        await AsyncXCTAssertEqual(await iterator.next(), 0)
        await AsyncXCTAssertEqual(await iterator.next(), 1)
        
        var bufferedIterator = AsyncBufferedIterator(iterator)
        
        await AsyncXCTAssertEqual(await bufferedIterator.next(), 2)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), 3)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), 4)
        await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), true)
        await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), true)
        await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), true)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), 5)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), 6)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), 7)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), 8)
        await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), true)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), 9)
        await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), false)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), nil)
        await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), false)
        await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), false)
        await AsyncXCTAssertEqual(await bufferedIterator.next(), nil)
    }
    
    func testReadSequenceFromThrowingTestSequence() async throws {
        let testStream = ThrowingTestSequence(base: 0..<10)
        
        var iterator = testStream.makeAsyncIterator()
        
        try await AsyncXCTAssertEqual(await iterator.next(), 0)
        try await AsyncXCTAssertEqual(await iterator.next(), 1)
        
        iterator = testStream.makeAsyncIterator()
        
        try await AsyncXCTAssertEqual(await iterator.next(), 0)
        try await AsyncXCTAssertEqual(await iterator.next(), 1)
        
        var bufferedIterator = AsyncBufferedIterator(iterator)
        
        try await AsyncXCTAssertEqual(await bufferedIterator.next(), 2)
        try await AsyncXCTAssertEqual(await bufferedIterator.next(), 3)
        try await AsyncXCTAssertEqual(await bufferedIterator.next(), 4)
        try await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), true)
        try await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), true)
        try await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), true)
        try await AsyncXCTAssertEqual(await bufferedIterator.next(), 5)
        try await AsyncXCTAssertEqual(await bufferedIterator.next(), 6)
        try await AsyncXCTAssertEqual(await bufferedIterator.next(), 7)
        try await AsyncXCTAssertEqual(await bufferedIterator.next(), 8)
        try await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), true)
        try await AsyncXCTAssertEqual(await bufferedIterator.next(), 9)
        try await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), false)
        try await AsyncXCTAssertEqual(await bufferedIterator.next(), nil)
        try await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), false)
        try await AsyncXCTAssertEqual(await bufferedIterator.hasMoreData(), false)
        try await AsyncXCTAssertEqual(await bufferedIterator.next(), nil)
    }
}
