//
//  AsyncSequenceReaderTests.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-16.
//  Copyright © 2021 Mochi Development, Inc. All rights reserved.
//

import XCTest
@testable import AsyncSequenceReader

final class AsyncSequenceReaderTests: XCTestCase {
    // MARK: - Test Manual Iteration
    
    func testReadSequenceFromStream() async throws {
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
        
        try await AsyncXCTAssertEqual(await readSequenceAIterator.next(), 0)
        try await AsyncXCTAssertEqual(await readSequenceAIterator.next(), 1)
        try await AsyncXCTAssertEqual(await readSequenceAIterator.next(), 2)
        try await AsyncXCTAssertEqual(await readSequenceAIterator.next(), 3)
        
        iterator = readSequenceA.baseIterator
        
        var totalRead: Int = 0
        let readSequenceB = AsyncSequenceReader(iterator) { iterator in
            guard totalRead < 4 else { return nil }
            let next = await iterator.next()
            totalRead += 1
            return next
        }
        
        var readSequenceBIterator = readSequenceB.makeAsyncIterator()
        
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), 4)
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), 5)
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), 6)
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), 7)
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), nil)
        
        iterator = readSequenceB.baseIterator
        
        await AsyncXCTAssertEqual(await iterator.next(), 8)
        await AsyncXCTAssertEqual(await iterator.next(), 9)
        await AsyncXCTAssertEqual(await iterator.next(), nil)
    }
    
    func testReadSequenceFromTestSequence() async throws {
        let testStream = TestSequence(base: 0..<10)
        
        var iterator = AsyncBufferedIterator(testStream.makeAsyncIterator())
        
        let readSequenceA = AsyncSequenceReader(iterator) { iterator in
            let next = await iterator.next()
            return next
        }
        
        var readSequenceAIterator = readSequenceA.makeAsyncIterator()
        
        try await AsyncXCTAssertEqual(await readSequenceAIterator.next(), 0)
        try await AsyncXCTAssertEqual(await readSequenceAIterator.next(), 1)
        try await AsyncXCTAssertEqual(await readSequenceAIterator.next(), 2)
        try await AsyncXCTAssertEqual(await readSequenceAIterator.next(), 3)
        
        iterator = readSequenceA.baseIterator
        
        var totalRead: Int = 0
        let readSequenceB = AsyncSequenceReader(iterator) { iterator in
            guard totalRead < 4 else { return nil }
            let next = await iterator.next()
            totalRead += 1
            return next
        }
        
        var readSequenceBIterator = readSequenceB.makeAsyncIterator()
        
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), 4)
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), 5)
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), 6)
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), 7)
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), nil)
        
        iterator = readSequenceB.baseIterator
        
        await AsyncXCTAssertEqual(await iterator.next(), 8)
        await AsyncXCTAssertEqual(await iterator.next(), 9)
        await AsyncXCTAssertEqual(await iterator.next(), nil)
    }
    
    func testReadSequenceFromThrowingTestSequence() async throws {
        let testStream = ThrowingTestSequence(base: 0..<10)
        
        var iterator = AsyncBufferedIterator(testStream.makeAsyncIterator())
        
        let readSequenceA = AsyncSequenceReader(iterator) { iterator in
            let next = try await iterator.next()
            return next
        }
        
        var readSequenceAIterator = readSequenceA.makeAsyncIterator()
        
        try await AsyncXCTAssertEqual(await readSequenceAIterator.next(), 0)
        try await AsyncXCTAssertEqual(await readSequenceAIterator.next(), 1)
        try await AsyncXCTAssertEqual(await readSequenceAIterator.next(), 2)
        try await AsyncXCTAssertEqual(await readSequenceAIterator.next(), 3)
        
        iterator = readSequenceA.baseIterator
        
        var totalRead: Int = 0
        let readSequenceB = AsyncSequenceReader(iterator) { iterator in
            guard totalRead < 4 else { return nil }
            let next = try await iterator.next()
            totalRead += 1
            return next
        }
        
        var readSequenceBIterator = readSequenceB.makeAsyncIterator()
        
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), 4)
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), 5)
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), 6)
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), 7)
        try await AsyncXCTAssertEqual(await readSequenceBIterator.next(), nil)
        
        iterator = readSequenceB.baseIterator
        
        try await AsyncXCTAssertEqual(await iterator.next(), 8)
        try await AsyncXCTAssertEqual(await iterator.next(), 9)
        try await AsyncXCTAssertEqual(await iterator.next(), nil)
    }
    
    // MARK: - Test Transforms
    
    func countCharacters<ReadSequence: AsyncReadSequence>(_ sequence: ReadSequence) async throws -> Int? where ReadSequence.Element == String {
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
    
    func testTransformSequenceFromStream() async throws {
        let testStream = AsyncStream<String> { continuation in
            let data = ["A", "few", "words", "to", "consider", "today", "as", "this", "test", "runs"]
            for value in data {
                continuation.yield(value)
            }
            continuation.finish()
        }
        
        var iterator = testStream.makeAsyncIterator()
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), 11)
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), 19)
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), 8)
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), nil)
        
        var iteratorB = testStream.makeAsyncIterator()
        try await AsyncXCTAssertEqual(await iteratorB.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), nil)
    }
    
    func testTransformSequenceFromBufferedStream() async throws {
        let testStream = AsyncStream<String> { continuation in
            let data = ["A", "few", "words", "to", "consider", "today", "as", "this", "test", "runs"]
            for value in data {
                continuation.yield(value)
            }
            continuation.finish()
        }
        
        var iterator = AsyncBufferedIterator(testStream.makeAsyncIterator())
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), 11)
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), 19)
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), 8)
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), nil)
        
        var iteratorB = AsyncBufferedIterator(testStream.makeAsyncIterator())
        try await AsyncXCTAssertEqual(await iteratorB.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), nil)
    }
    
    func testTransformSequenceFromTestSequence() async throws {
        let testStream = TestSequence(base: ["A", "few", "words", "to", "consider", "today", "as", "this", "test", "runs"])
        
        var iterator = testStream.makeAsyncIterator()
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), 11)
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), 19)
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), 8)
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), nil)
        
        var iteratorB = testStream.makeAsyncIterator()
        try await AsyncXCTAssertEqual(await iteratorB.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), 11)
    }
    
    func testTransformSequenceFromThrowingTestSequence() async throws {
        let testStream = ThrowingTestSequence(base: ["A", "few", "words", "to", "consider", "today", "as", "this", "test", "runs"])
        
        var iterator = testStream.makeAsyncIterator()
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), 11)
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), 19)
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), 8)
        try await AsyncXCTAssertEqual(await iterator.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), nil)
        
        var iteratorB = testStream.makeAsyncIterator()
        try await AsyncXCTAssertEqual(await iteratorB.transform(with: countCharacters, readSequenceFactory: makeReadFourElementSequence), 11)
    }
}
