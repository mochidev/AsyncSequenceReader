//
//  AsyncIteratorMapSequenceTests.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-16.
//  Copyright © 2021 Mochi Development, Inc. All rights reserved.
//

import XCTest
@testable import AsyncSequenceReader

final class AsyncIteratorMapSequenceTests: XCTestCase, @unchecked Sendable {
    func testIteratorMapFromStream() async throws {
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
        
        await AsyncXCTAssertEqual(await resultsIterator.next(), "Hello, World!")
        await AsyncXCTAssertEqual(await resultsIterator.next(), "My name is Dimitri.")
        await AsyncXCTAssertEqual(await resultsIterator.next(), "")
        await AsyncXCTAssertEqual(await resultsIterator.next(), "Bye!")
    }
    
    func testIteratorMapFromInvalidStream() async throws {
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
        
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Hello, World!")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "My name is Dimitri.")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "")
        do {
            try await AsyncXCTAssertEqual(await resultsIterator.next(), "Bye!")
            XCTFail("This should not succeed.")
        } catch is LocalError {
            
        }
    }
    
    func testIteratorMapFromTestSequence() async throws {
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
        
        await AsyncXCTAssertEqual(await resultsIterator.next(), "Hello, World!")
        await AsyncXCTAssertEqual(await resultsIterator.next(), "My name is Dimitri.")
        await AsyncXCTAssertEqual(await resultsIterator.next(), "")
        await AsyncXCTAssertEqual(await resultsIterator.next(), "Bye!")
    }
    
    func testIteratorMapFromInvalidTestSequence() async throws {
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
        
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Hello, World!")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "My name is Dimitri.")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "")
        do {
            try await AsyncXCTAssertEqual(await resultsIterator.next(), "Bye!")
            XCTFail("This should not succeed.")
        } catch is LocalError {
            
        }
    }
    
    func testIteratorMapFromThrowingTestSequence() async throws {
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
        
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Hello, World!")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "My name is Dimitri.")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Bye!")
    }
    
    func testIteratorMapFromInvalidThrowingTestSequence() async throws {
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
        
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Hello, World!")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "My name is Dimitri.")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "")
        do {
            try await AsyncXCTAssertEqual(await resultsIterator.next(), "Bye!")
            XCTFail("This should not succeed.")
        } catch is LocalError {
            
        }
    }
}
