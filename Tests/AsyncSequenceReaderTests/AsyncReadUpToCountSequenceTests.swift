//
//  AsyncReadUpToCountSequenceTests.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-17.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

@testable import AsyncSequenceReader
import Testing

@Suite struct AsyncReadUpToCountSequenceTests {
    @Test func iteratorMapFromStream() async throws {
        struct LocalError: Error {}
        
        let testStream = AsyncStream<String> { continuation in
            let data = ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "1", "Bye!"]
            for value in data {
                continuation.yield(value)
            }
            continuation.finish()
        }
        
        let results = testStream.iteratorMap { iterator -> String? in
            guard let count = Int(await iterator.next() ?? "") else {
                throw LocalError()
            }
            
            let value = try await iterator.collect(count) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + $1 }
            }
            
            return value
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "Hello, World!")
        #expect(try await resultsIterator.next() == "My name is Dimitri.")
        #expect(try await resultsIterator.next() == "")
        #expect(try await resultsIterator.next() == "Bye!")
    }
    
    @Test func iteratorMapFromInvalidStream() async throws {
        struct LocalError: Error {}
        
        let testStream = AsyncStream<String> { continuation in
            let data = ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "2", "Bye!"]
            for value in data {
                continuation.yield(value)
            }
            continuation.finish()
        }
        
        let results = testStream.iteratorMap { iterator -> String? in
            guard let count = Int(await iterator.next() ?? "") else {
                throw LocalError()
            }
            
            let value = try await iterator.collect(count) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + $1 }
            }
            
            return value
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "Hello, World!")
        #expect(try await resultsIterator.next() == "My name is Dimitri.")
        #expect(try await resultsIterator.next() == "")
        await #expect(throws: AsyncSequenceReaderError.insufficientElements(minimum: 2, actual: 1)) {
            try await resultsIterator.next()
        }
    }
    
    @Test func looseIteratorMapFromInvalidStream() async throws {
        struct LocalError: Error {}
        
        let testStream = AsyncStream<String> { continuation in
            let data = ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "2", "Bye!"]
            for value in data {
                continuation.yield(value)
            }
            continuation.finish()
        }
        
        let results = testStream.iteratorMap { iterator -> String? in
            guard let count = Int(await iterator.next() ?? "") else {
                throw LocalError()
            }
            
            let value = try await iterator.collect(min: 0, max: count) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + $1 }
            }
            
            return value
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "Hello, World!")
        #expect(try await resultsIterator.next() == "My name is Dimitri.")
        #expect(try await resultsIterator.next() == "")
        #expect(try await resultsIterator.next() == "Bye!")
    }
    
    @Test func iteratorMapFromTestSequence() async throws {
        struct LocalError: Error {}
        
        let testStream = TestSequence(base: ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "1", "Bye!"])
        
        let results = testStream.iteratorMap { iterator -> String? in
            guard let count = Int(await iterator.next() ?? "") else {
                throw LocalError()
            }
            
            let value = try await iterator.collect(count) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + $1 }
            }
            
            return value
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "Hello, World!")
        #expect(try await resultsIterator.next() == "My name is Dimitri.")
        #expect(try await resultsIterator.next() == "")
        #expect(try await resultsIterator.next() == "Bye!")
    }
    
    @Test func iteratorMapFromInvalidTestSequence() async throws {
        struct LocalError: Error {}
        
        let testStream = TestSequence(base: ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "2", "Bye!"])
        
        let results = testStream.iteratorMap { iterator -> String? in
            guard let count = Int(await iterator.next() ?? "") else {
                throw LocalError()
            }
            
            let value = try await iterator.collect(count) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + $1 }
            }
            
            return value
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "Hello, World!")
        #expect(try await resultsIterator.next() == "My name is Dimitri.")
        #expect(try await resultsIterator.next() == "")
        await #expect(throws: AsyncSequenceReaderError.insufficientElements(minimum: 2, actual: 1)) {
            try await resultsIterator.next()
        }
    }
    
    @Test func iteratorMapFromThrowingTestSequence() async throws {
        struct LocalError: Error {}
        
        let testStream = ThrowingTestSequence(base: ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "1", "Bye!"])
        
        let results = testStream.iteratorMap { iterator -> String? in
            guard let count = Int(try await iterator.next() ?? "") else {
                throw LocalError()
            }
            
            let value = try await iterator.collect(count) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + $1 }
            }
            
            return value
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "Hello, World!")
        #expect(try await resultsIterator.next() == "My name is Dimitri.")
        #expect(try await resultsIterator.next() == "")
        #expect(try await resultsIterator.next() == "Bye!")
    }
    
    @Test func iteratorMapFromInvalidThrowingTestSequence() async throws {
        struct LocalError: Error {}
        
        let testStream = ThrowingTestSequence(base: ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "2", "Bye!"])
        
        let results = testStream.iteratorMap { iterator -> String? in
            guard let count = Int(try await iterator.next() ?? "") else {
                throw LocalError()
            }
            
            let value = try await iterator.collect(count) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + $1 }
            }
            
            return value
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "Hello, World!")
        #expect(try await resultsIterator.next() == "My name is Dimitri.")
        #expect(try await resultsIterator.next() == "")
        await #expect(throws: AsyncSequenceReaderError.insufficientElements(minimum: 2, actual: 1)) {
            try await resultsIterator.next()
        }
    }
}
