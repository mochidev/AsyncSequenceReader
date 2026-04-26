//
//  AsyncReadUpToElementsSequenceTests.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-17.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

@testable import AsyncSequenceReader
import Testing

@Suite struct AsyncReadUpToElementsSequenceTests {
    @Test func iteratorMapUpToIncludingSequence() async throws {
        struct LocalError: Error {}
        
        let testStream = TestSequence(base: "apple orange banana kiwi kumquat pear pineapple")
        
        let results = testStream.iteratorMap { iterator -> String? in
            let word = try await iterator.collect(upToIncluding: " ") { sequence -> String in
                try await sequence.reduce(into: "") { $0.append($1) }
            }
            
            if let word = word, word.hasSuffix(" ") {
                return String(word.dropLast(1))
            }
            return word
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple")
        #expect(try await resultsIterator.next() == "orange")
        #expect(try await resultsIterator.next() == "banana")
        #expect(try await resultsIterator.next() == "kiwi")
        #expect(try await resultsIterator.next() == "kumquat")
        #expect(try await resultsIterator.next() == "pear")
        #expect(try await resultsIterator.next() == "pineapple")
    }
    
    @Test func iteratorMapUpToIncluding() async throws {
        struct LocalError: Error {}
        
        let testStream = TestSequence(base: "apple orange banana kiwi kumquat pear pineapple ")
        
        let results = testStream.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToIncluding: " ", throwsIfOver: 100)).map { String($0.dropLast()) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple")
        #expect(try await resultsIterator.next() == "orange")
        #expect(try await resultsIterator.next() == "banana")
        #expect(try await resultsIterator.next() == "kiwi")
        #expect(try await resultsIterator.next() == "kumquat")
        #expect(try await resultsIterator.next() == "pear")
        #expect(try await resultsIterator.next() == "pineapple")
    }
    
    @Test func iteratorMapUpToExcluding() async throws {
        struct LocalError: Error {}
        
        let testStream = TestSequence(base: "apple orange banana kiwi kumquat pear pineapple ")
        
        let results = testStream.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToExcluding: " ", throwsIfOver: 100)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple")
        #expect(try await resultsIterator.next() == "orange")
        #expect(try await resultsIterator.next() == "banana")
        #expect(try await resultsIterator.next() == "kiwi")
        #expect(try await resultsIterator.next() == "kumquat")
        #expect(try await resultsIterator.next() == "pear")
        #expect(try await resultsIterator.next() == "pineapple")
    }
}
