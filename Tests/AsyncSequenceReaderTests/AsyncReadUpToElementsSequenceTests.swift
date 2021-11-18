//
//  AsyncReadUpToElementsSequenceTests.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-17.
//  Copyright © 2021 Mochi Development, Inc. All rights reserved.
//

import XCTest
@testable import AsyncSequenceReader

final class AsyncReadUpToElementsSequenceTests: XCTestCase {
    func testIteratorMapUpToIncludingSequence() async throws {
        struct LocalError: Error {}
        
        let testStream = TestSequence(base: "apple orange banana kiwi kumquat pear pineapple")
        
        let results = testStream.iteratorMap { iterator -> String? in
            let word = await iterator.collect(upToIncluding: " ") { sequence -> String in
                await sequence.reduce(into: "") { $0.append($1) }
            }
            
            if let word = word, word.hasSuffix(" ") {
                return String(word.dropLast(1))
            }
            return word
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        await AsyncXCTAssertEqual(await resultsIterator.next(), "apple")
        await AsyncXCTAssertEqual(await resultsIterator.next(), "orange")
        await AsyncXCTAssertEqual(await resultsIterator.next(), "banana")
        await AsyncXCTAssertEqual(await resultsIterator.next(), "kiwi")
        await AsyncXCTAssertEqual(await resultsIterator.next(), "kumquat")
        await AsyncXCTAssertEqual(await resultsIterator.next(), "pear")
        await AsyncXCTAssertEqual(await resultsIterator.next(), "pineapple")
    }
    
    func testIteratorMapUpToIncluding() async throws {
        struct LocalError: Error {}
        
        let testStream = TestSequence(base: "apple orange banana kiwi kumquat pear pineapple ")
        
        let results = testStream.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToIncluding: " ", throwsIfOver: 100)).map { String($0.dropLast()) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "apple")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "orange")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "banana")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "kiwi")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "kumquat")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "pear")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "pineapple")
    }
    
    func testIteratorMapUpToExcluding() async throws {
        struct LocalError: Error {}
        
        let testStream = TestSequence(base: "apple orange banana kiwi kumquat pear pineapple ")
        
        let results = testStream.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToExcluding: " ", throwsIfOver: 100)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "apple")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "orange")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "banana")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "kiwi")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "kumquat")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "pear")
        try await AsyncXCTAssertEqual(await resultsIterator.next(), "pineapple")
    }
}
