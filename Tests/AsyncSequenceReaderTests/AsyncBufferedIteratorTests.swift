//
//  AsyncBufferedIteratorTests.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-16.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

@testable import AsyncSequenceReader
import Testing

@Suite struct AsyncBufferedIteratorTests {
    @Test func bufferIteratorFromStream() async throws {
        let testStream = AsyncStream<Int> { continuation in
            for value in 0..<10 {
                continuation.yield(value)
            }
            continuation.finish()
        }
        
        var iterator = testStream.makeAsyncIterator()
        
        #expect(await iterator.next() == 0)
        #expect(await iterator.next() == 1)
        
        iterator = testStream.makeAsyncIterator()
        
        #expect(await iterator.next() == 2)
        #expect(await iterator.next() == 3)
        
        var bufferedIterator = AsyncBufferedIterator(iterator)
        
        #expect(await bufferedIterator.next() == 4)
        #expect(await bufferedIterator.hasMoreData() == true)
        #expect(await bufferedIterator.hasMoreData() == true)
        #expect(await bufferedIterator.hasMoreData() == true)
        #expect(await bufferedIterator.next() == 5)
        #expect(await bufferedIterator.nonIsolatedNext() == 6)
        #expect(await bufferedIterator.next() == 7)
        #expect(await bufferedIterator.next() == 8)
        #expect(await bufferedIterator.hasMoreData() == true)
        #expect(await bufferedIterator.next() == 9)
        #expect(await bufferedIterator.hasMoreData() == false)
        #expect(await bufferedIterator.next() == nil)
        #expect(await bufferedIterator.hasMoreData() == false)
        #expect(await bufferedIterator.hasMoreData() == false)
        #expect(await bufferedIterator.next() == nil)
    }
    
    @Test func bufferIteratorFromTestSequence() async throws {
        let testStream = TestSequence(base: 0..<10)
        
        var iterator = testStream.makeAsyncIterator()
        
        #expect(await iterator.next() == 0)
        #expect(await iterator.next() == 1)
        
        iterator = testStream.makeAsyncIterator()
        
        #expect(await iterator.next() == 0)
        #expect(await iterator.next() == 1)
        
        var bufferedIterator = AsyncBufferedIterator<_, Never>(iterator)
        
        #expect(await bufferedIterator.next() == 2)
        #expect(await bufferedIterator.next() == 3)
        #expect(await bufferedIterator.next() == 4)
        #expect(await bufferedIterator.hasMoreData() == true)
        #expect(await bufferedIterator.hasMoreData() == true)
        #expect(await bufferedIterator.hasMoreData() == true)
        #expect(await bufferedIterator.next() == 5)
        #expect(await bufferedIterator.nonIsolatedNext() == 6)
        #expect(await bufferedIterator.next() == 7)
        #expect(await bufferedIterator.next() == 8)
        #expect(await bufferedIterator.hasMoreData() == true)
        #expect(await bufferedIterator.next() == 9)
        #expect(await bufferedIterator.hasMoreData() == false)
        #expect(await bufferedIterator.next() == nil)
        #expect(await bufferedIterator.hasMoreData() == false)
        #expect(await bufferedIterator.hasMoreData() == false)
        #expect(await bufferedIterator.next() == nil)
    }
    
    @Test func readSequenceFromThrowingTestSequence() async throws {
        let testStream = ThrowingTestSequence(base: 0..<10)
        
        var iterator = testStream.makeAsyncIterator()
        
        #expect(try await iterator.next() == 0)
        #expect(try await iterator.next() == 1)
        
        iterator = testStream.makeAsyncIterator()
        
        #expect(try await iterator.next() == 0)
        #expect(try await iterator.next() == 1)
        
        var bufferedIterator = AsyncBufferedIterator(iterator)
        
        #expect(try await bufferedIterator.next() == 2)
        #expect(try await bufferedIterator.next() == 3)
        #expect(try await bufferedIterator.next() == 4)
        #expect(await bufferedIterator.hasMoreData() == true)
        #expect(await bufferedIterator.hasMoreData() == true)
        #expect(await bufferedIterator.hasMoreData() == true)
        #expect(try await bufferedIterator.next() == 5)
        #expect(try await bufferedIterator.nonIsolatedNext() == 6)
        #expect(try await bufferedIterator.next() == 7)
        #expect(try await bufferedIterator.next() == 8)
        #expect(await bufferedIterator.hasMoreData() == true)
        #expect(try await bufferedIterator.next() == 9)
        #expect(await bufferedIterator.hasMoreData() == false)
        #expect(try await bufferedIterator.next() == nil)
        #expect(await bufferedIterator.hasMoreData() == false)
        #expect(await bufferedIterator.hasMoreData() == false)
        #expect(try await bufferedIterator.next() == nil)
    }
}
