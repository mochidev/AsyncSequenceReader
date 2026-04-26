//
//  AsyncSequenceReaderTests.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-16.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

@testable import AsyncSequenceReader
import Testing

@Suite struct AsyncSequenceReaderTests {
    // MARK: - Test Manual Iteration
    
    @Test func readSequenceFromStream() async throws {
        let testStream = AsyncStream<Int> { continuation in
            for value in 0..<10 {
                continuation.yield(value)
            }
            continuation.finish()
        }
        
        var iterator = AsyncBufferedIterator(testStream.makeAsyncIterator())
        
        let readSequenceA = AsyncSequenceReader(iterator) { iterator in
            let next = await iterator.next()
            return next
        }
        
        var readSequenceAIterator = readSequenceA.makeAsyncIterator()
        
        #expect(try await readSequenceAIterator.next() == 0)
        #expect(try await readSequenceAIterator.next() == 1)
        #expect(try await readSequenceAIterator.next() == 2)
        #expect(try await readSequenceAIterator.next() == 3)
        
        iterator = readSequenceA.baseIterator
        
        var totalRead: Int = 0
        let readSequenceB = AsyncSequenceReader(iterator) { iterator in
            guard totalRead < 4 else { return nil }
            let next = await iterator.next()
            totalRead += 1
            return next
        }
        
        var readSequenceBIterator = readSequenceB.makeAsyncIterator()
        
        #expect(try await readSequenceBIterator.next() == 4)
        #expect(try await readSequenceBIterator.next() == 5)
        #expect(try await readSequenceBIterator.next() == 6)
        #expect(try await readSequenceBIterator.next() == 7)
        #expect(try await readSequenceBIterator.next() == nil)
        
        iterator = readSequenceB.baseIterator
        
        #expect(await iterator.next() == 8)
        #expect(await iterator.next() == 9)
        #expect(await iterator.next() == nil)
    }
    
    @Test func readSequenceFromTestSequence() async throws {
        let testStream = TestSequence(base: 0..<10)
        
        var iterator = AsyncBufferedIterator(testStream.makeAsyncIterator())
        
        let readSequenceA = AsyncSequenceReader(iterator) { iterator in
            let next = await iterator.next()
            return next
        }
        
        var readSequenceAIterator = readSequenceA.makeAsyncIterator()
        
        #expect(try await readSequenceAIterator.next() == 0)
        #expect(try await readSequenceAIterator.next() == 1)
        #expect(try await readSequenceAIterator.next() == 2)
        #expect(try await readSequenceAIterator.next() == 3)
        
        iterator = readSequenceA.baseIterator
        
        var totalRead: Int = 0
        let readSequenceB = AsyncSequenceReader(iterator) { iterator in
            guard totalRead < 4 else { return nil }
            let next = await iterator.next()
            totalRead += 1
            return next
        }
        
        var readSequenceBIterator = readSequenceB.makeAsyncIterator()
        
        #expect(try await readSequenceBIterator.next() == 4)
        #expect(try await readSequenceBIterator.next() == 5)
        #expect(try await readSequenceBIterator.next() == 6)
        #expect(try await readSequenceBIterator.next() == 7)
        #expect(try await readSequenceBIterator.next() == nil)
        
        iterator = readSequenceB.baseIterator
        
        #expect(await iterator.next() == 8)
        #expect(await iterator.next() == 9)
        #expect(await iterator.next() == nil)
    }
    
    @Test func readSequenceFromThrowingTestSequence() async throws {
        let testStream = ThrowingTestSequence(base: 0..<10)
        
        var iterator = AsyncBufferedIterator(testStream.makeAsyncIterator())
        
        let readSequenceA = AsyncSequenceReader(iterator) { iterator in
            let next = try await iterator.next()
            return next
        }
        
        var readSequenceAIterator = readSequenceA.makeAsyncIterator()
        
        #expect(try await readSequenceAIterator.next() == 0)
        #expect(try await readSequenceAIterator.next() == 1)
        #expect(try await readSequenceAIterator.next() == 2)
        #expect(try await readSequenceAIterator.next() == 3)
        
        iterator = readSequenceA.baseIterator
        
        var totalRead: Int = 0
        let readSequenceB = AsyncSequenceReader(iterator) { iterator in
            guard totalRead < 4 else { return nil }
            let next = try await iterator.next()
            totalRead += 1
            return next
        }
        
        var readSequenceBIterator = readSequenceB.makeAsyncIterator()
        
        #expect(try await readSequenceBIterator.next() == 4)
        #expect(try await readSequenceBIterator.next() == 5)
        #expect(try await readSequenceBIterator.next() == 6)
        #expect(try await readSequenceBIterator.next() == 7)
        #expect(try await readSequenceBIterator.next() == nil)
        
        iterator = readSequenceB.baseIterator
        
        #expect(try await iterator.next() == 8)
        #expect(try await iterator.next() == 9)
        #expect(try await iterator.next() == nil)
    }
    
    // MARK: - Test Transforms
    
    func countCharacters<ReadSequence: AsyncReadSequence>(_ sequence: sending ReadSequence) async throws -> Int? where ReadSequence.Element == String {
        try await sequence.map { $0.count }.reduce(into: 0) { partialResult, next in
            partialResult += next
        }
    }
    
    func makeReadFourElementSequence<BaseIterator>(_ iterator: inout AsyncBufferedIterator<BaseIterator>) -> AsyncSequenceReader<BaseIterator> {
        var totalRead: Int = 0
        return AsyncSequenceReader(iterator) { iterator in
            guard totalRead < 4 else { return nil }
            let next = try await iterator.next()
            totalRead += 1
            return next
        }
    }
    
    @Test func transformSequenceFromStream() async throws {
        let testStream = AsyncStream<String> { continuation in
            let data = ["A", "few", "words", "to", "consider", "today", "as", "this", "test", "runs"]
            for value in data {
                continuation.yield(value)
            }
            continuation.finish()
        }
        
        var iterator = testStream.makeAsyncIterator()
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == 11)
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == 19)
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == 8)
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == nil)
        
        var iteratorB = testStream.makeAsyncIterator()
        #expect(try await iteratorB.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == nil)
    }
    
    @Test func transformSequenceFromBufferedStream() async throws {
        let testStream = AsyncStream<String> { continuation in
            let data = ["A", "few", "words", "to", "consider", "today", "as", "this", "test", "runs"]
            for value in data {
                continuation.yield(value)
            }
            continuation.finish()
        }
        
        var iterator = AsyncBufferedIterator(testStream.makeAsyncIterator())
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == 11)
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == 19)
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == 8)
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == nil)
        
        var iteratorB = AsyncBufferedIterator(testStream.makeAsyncIterator())
        #expect(try await iteratorB.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == nil)
    }
    
    @Test func transformSequenceFromTestSequence() async throws {
        let testStream = TestSequence(base: ["A", "few", "words", "to", "consider", "today", "as", "this", "test", "runs"])
        
        var iterator = testStream.makeAsyncIterator()
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == 11)
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == 19)
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == 8)
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == nil)
        
        var iteratorB = testStream.makeAsyncIterator()
        #expect(try await iteratorB.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == 11)
    }
    
    @Test func transformSequenceFromThrowingTestSequence() async throws {
        let testStream = ThrowingTestSequence(base: ["A", "few", "words", "to", "consider", "today", "as", "this", "test", "runs"])
        
        var iterator = testStream.makeAsyncIterator()
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == 11)
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == 19)
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == 8)
        #expect(try await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == nil)
        
        var iteratorB = testStream.makeAsyncIterator()
        #expect(try await iteratorB.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence) == 11)
    }
    
    @Test func transformNotCalledForEmptyBufferedStream() async throws {
        let testStream = AsyncStream<String> { continuation in
            continuation.finish()
        }
        
        var iterator = AsyncBufferedIterator(testStream.makeAsyncIterator())
        #expect(try await iterator.transform(with: { sequence in
            Issue.record("Transformation should never be called!")
        }, readSequenceFactory: { iterator in
            Issue.record("Factory should never be called!")
            return AsyncSequenceReader(iterator) { await $0.next() }
        }) == nil)
    }
    
    @Test func transformNotCalledForEmptyTestSequence() async throws {
        let testStream = TestSequence(base: [])
        
        var iterator = testStream.makeAsyncIterator()
        #expect(try await iterator.transform(with: { sequence in
            Issue.record("Transformation should never be called!")
        }, readSequenceFactory: { iterator in
            Issue.record("Factory should never be called!")
            return AsyncSequenceReader(iterator) { await $0.next() }
        }) == nil)
    }
    
    @Test func transformNotCalledForEmptyStream() async throws {
        let testStream = AsyncStream<String> { continuation in
            continuation.finish()
        }
        
        var iterator = testStream.makeAsyncIterator()
        #expect(try await iterator.transform(with: { sequence in
            Issue.record("Transformation should never be called!")
        }, readSequenceFactory: { iterator in
            Issue.record("Factory should never be called!")
            return AsyncSequenceReader(iterator) { await $0.next() }
        }) == nil)
    }
}
