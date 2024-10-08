//
//  AsyncReadUpToCountSequenceTests.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-17.
//  Copyright © 2021 Mochi Development, Inc. All rights reserved.
//

import XCTest
@testable import AsyncSequenceReader

final class AsyncReadUpToCountSequenceTests: XCTestCase, @unchecked Sendable {
    func testIteratorMapFromStream() async throws {
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
        
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Hello, World!")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "My name is Dimitri.")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Bye!")
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
            guard let count = Int(await iterator.next() ?? "") else {
                throw LocalError()
            }
            
            let value = try await iterator.collect(count) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + $1 }
            }
            
            return value
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Hello, World!")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "My name is Dimitri.")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "")
        do {
            try await AsyncXCTAssertEqual(await resultsIterator.next(), "Bye!")
            XCTFail("This should not succeed.")
        } catch AsyncSequenceReaderError.insufficientElements(minimum: 2, actual: 1) {
            
        }
    }
    
    func testLooseIteratorMapFromInvalidStream() async throws {
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
        
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Hello, World!")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "My name is Dimitri.")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Bye!")
    }
    
    func testIteratorMapFromTestSequence() async throws {
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
        
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Hello, World!")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "My name is Dimitri.")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Bye!")
    }
    
    func testIteratorMapFromInvalidTestSequence() async throws {
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
        
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Hello, World!")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "My name is Dimitri.")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "")
        do {
            try await AsyncXCTAssertEqual(await resultsIterator.next(), "Bye!")
            XCTFail("This should not succeed.")
        } catch AsyncSequenceReaderError.insufficientElements(minimum: 2, actual: 1) {
            
        }
    }
    
    func testIteratorMapFromThrowingTestSequence() async throws {
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
        
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Hello, World!")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "My name is Dimitri.")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Bye!")
    }
    
    func testIteratorMapFromInvalidThrowingTestSequence() async throws {
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
        
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "Hello, World!")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "My name is Dimitri.")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "")
        do {
            try await AsyncXCTAssertEqual(await resultsIterator.next(), "Bye!")
            XCTFail("This should not succeed.")
        } catch AsyncSequenceReaderError.insufficientElements(minimum: 2, actual: 1) {
            
        }
    }
}
