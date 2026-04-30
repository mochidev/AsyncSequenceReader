//
//  AsyncIteratorMapSequenceTests.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-16.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

@testable import AsyncSequenceReader
import Testing

@Suite struct AsyncIteratorMapSequenceTests {
    @Test func iteratorMapFromStream() async throws {
        let testStream = AsyncStream<String> { continuation in
            let data = ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "1", "Bye!"]
            for value in data {
                continuation.yield(value)
            }
            continuation.finish()
        }
        
        let results = testStream.iteratorMap { iterator -> String? in
            var count = Int(await iterator.next() ?? "")!
            
            var results: [String] = []
            
            while count > 0, let next = await iterator.next() {
                results.append(next)
                count -= 1
            }
            
            return results.joined(separator: " ")
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(await resultsIterator.next() == "Hello, World!")
        #expect(await resultsIterator.next() == "My name is Dimitri.")
        #expect(await resultsIterator.next() == "")
        #expect(await resultsIterator.next() == "Bye!")
        #expect(await resultsIterator.next() == nil)
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
            var count = Int(await iterator.next() ?? "")!
            
            var results: [String] = []
            
            while count > 0, let next = await iterator.next() {
                results.append(next)
                count -= 1
            }
            
            guard count == 0 else {
                throw LocalError()
            }
            
            return results.joined(separator: " ")
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "Hello, World!")
        #expect(try await resultsIterator.next() == "My name is Dimitri.")
        #expect(try await resultsIterator.next() == "")
        await #expect(throws: LocalError.self) {
            try await resultsIterator.next()
        }
    }
    
    @Test func iteratorMapFromTestSequence() async throws {
        let testStream = TestSequence(base: ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "1", "Bye!"])
        
        let results = testStream.iteratorMap { iterator -> String? in
            var count = Int(await iterator.next() ?? "")!
            
            var results: [String] = []
            
            while count > 0, let next = await iterator.next() {
                results.append(next)
                count -= 1
            }
            
            return results.joined(separator: " ")
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(await resultsIterator.next() == "Hello, World!")
        #expect(await resultsIterator.next() == "My name is Dimitri.")
        #expect(await resultsIterator.next() == "")
        #expect(await resultsIterator.next() == "Bye!")
        #expect(await resultsIterator.next() == nil)
    }
    
    @Test func iteratorMapFromInvalidTestSequence() async throws {
        struct LocalError: Error {}
        
        let testStream = TestSequence(base: ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "2", "Bye!"])
        
        let results = testStream.iteratorMap { iterator -> String? in
            var count = Int(await iterator.next() ?? "")!
            
            var results: [String] = []
            
            while count > 0, let next = await iterator.next() {
                results.append(next)
                count -= 1
            }
            
            guard count == 0 else {
                throw LocalError()
            }
            
            return results.joined(separator: " ")
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "Hello, World!")
        #expect(try await resultsIterator.next() == "My name is Dimitri.")
        #expect(try await resultsIterator.next() == "")
        await #expect(throws: LocalError.self) {
            try await resultsIterator.next()
        }
    }
    
    @Test func iteratorMapFromThrowingTestSequence() async throws {
        let testStream = ThrowingTestSequence(base: ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "1", "Bye!"])
        
        let results = testStream.iteratorMap { iterator -> String? in
            var count = Int(try await iterator.next() ?? "")!
            
            var results: [String] = []
            
            while count > 0, let next = try await iterator.next() {
                results.append(next)
                count -= 1
            }
            
            return results.joined(separator: " ")
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "Hello, World!")
        #expect(try await resultsIterator.next() == "My name is Dimitri.")
        #expect(try await resultsIterator.next() == "")
        #expect(try await resultsIterator.next() == "Bye!")
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func iteratorMapFromInvalidThrowingTestSequence() async throws {
        struct LocalError: Error {}
        
        let testStream = ThrowingTestSequence(base: ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "2", "Bye!"])
        
        let results = testStream.iteratorMap { iterator -> String? in
            var count = Int(try await iterator.next() ?? "")!
            
            var results: [String] = []
            
            while count > 0, let next = try await iterator.next() {
                results.append(next)
                count -= 1
            }
            
            guard count == 0 else {
                throw LocalError()
            }
            
            return results.joined(separator: " ")
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "Hello, World!")
        #expect(try await resultsIterator.next() == "My name is Dimitri.")
        #expect(try await resultsIterator.next() == "")
        await #expect(throws: LocalError.self) {
            try await resultsIterator.next()
        }
    }
    
    @Test func iteratorMapFromSequence() async throws {
        let sequence = ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "1", "Bye!"]
        
        let results = sequence.iteratorMap { iterator -> String? in
            var count = Int(await iterator.next() ?? "")!
            
            var results: [String] = []
            
            while count > 0, let next = await iterator.next() {
                results.append(next)
                count -= 1
            }
            
            return results.joined(separator: " ")
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(await resultsIterator.next() == "Hello, World!")
        #expect(await resultsIterator.next() == "My name is Dimitri.")
        #expect(await resultsIterator.next() == "")
        #expect(await resultsIterator.next() == "Bye!")
        #expect(await resultsIterator.next() == nil)
    }
    
    @Test func iteratorMapFromInvalidSequence() async throws {
        struct LocalError: Error {}
        
        let sequence = ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "2", "Bye!"]
        
        let results = sequence.iteratorMap { iterator -> String? in
            var count = Int(await iterator.next() ?? "")!
            
            var results: [String] = []
            
            while count > 0, let next = await iterator.next() {
                results.append(next)
                count -= 1
            }
            
            guard count == 0 else {
                throw LocalError()
            }
            
            return results.joined(separator: " ")
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "Hello, World!")
        #expect(try await resultsIterator.next() == "My name is Dimitri.")
        #expect(try await resultsIterator.next() == "")
        await #expect(throws: LocalError.self) {
            try await resultsIterator.next()
        }
    }
}
