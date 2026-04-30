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
    @Test func upToIncludingReturnsNilIfEmpty() async throws {
        var iterator = AnyReadableSequence("").makeAsyncIterator()
        #expect(try await iterator.collect(upToIncluding: " " as Character, throwsIfOver: 10) == nil)
    }
    
    @Test func iteratorMapUpToIncluding() async throws {
        let inputSequence = "apple orange banana kiwi kumquat pear pineapple "
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToIncluding: " " as Character, throwsIfOver: 10)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple ")
        #expect(try await resultsIterator.next() == "orange ")
        #expect(try await resultsIterator.next() == "banana ")
        #expect(try await resultsIterator.next() == "kiwi ")
        #expect(try await resultsIterator.next() == "kumquat ")
        #expect(try await resultsIterator.next() == "pear ")
        #expect(try await resultsIterator.next() == "pineapple ")
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func iteratorMapUpToIncludingThrowsIfNotFound() async throws {
        let inputSequence = "apple orange banana kiwi kumquat pear pineapple"
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToIncluding: " " as Character, throwsIfOver: 10)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple ")
        #expect(try await resultsIterator.next() == "orange ")
        #expect(try await resultsIterator.next() == "banana ")
        #expect(try await resultsIterator.next() == "kiwi ")
        #expect(try await resultsIterator.next() == "kumquat ")
        #expect(try await resultsIterator.next() == "pear ")
        await #expect(throws: AsyncSequenceReaderError.terminationNotFound(maximum: 10, actual: 9)) {
            try await resultsIterator.next()
        }
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func iteratorMapUpToIncludingThrowsIfTooLong() async throws {
        let inputSequence = "apple orange banana kiwi kumquat pear pineapple apple pen"
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToIncluding: " " as Character, throwsIfOver: 9)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple ")
        #expect(try await resultsIterator.next() == "orange ")
        #expect(try await resultsIterator.next() == "banana ")
        #expect(try await resultsIterator.next() == "kiwi ")
        #expect(try await resultsIterator.next() == "kumquat ")
        #expect(try await resultsIterator.next() == "pear ")
        await #expect(throws: AsyncSequenceReaderError.terminationNotFound(maximum: 9, actual: 10)) {
            try await resultsIterator.next()
        }
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func upToIncludingSequenceReturnsNilIfEmpty() async throws {
        var iterator = AnyReadableSequence("").makeAsyncIterator()
        #expect(try await iterator.collect(upToIncluding: ", ", throwsIfOver: 10) == nil)
    }
    
    @Test func iteratorMapUpToIncludingSequence() async throws {
        let inputSequence = "apple orange, banana kiwi, kumquat pear, pineapple apple, "
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToIncluding: ", ", throwsIfOver: 17)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple orange, ")
        #expect(try await resultsIterator.next() == "banana kiwi, ")
        #expect(try await resultsIterator.next() == "kumquat pear, ")
        #expect(try await resultsIterator.next() == "pineapple apple, ")
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func iteratorMapUpToIncludingSequenceIfNotFound() async throws {
        let inputSequence = "apple orange, banana kiwi, kumquat pear, pineapple apple"
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToIncluding: ", ", throwsIfOver: 17)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple orange, ")
        #expect(try await resultsIterator.next() == "banana kiwi, ")
        #expect(try await resultsIterator.next() == "kumquat pear, ")
        await #expect(throws: AsyncSequenceReaderError.terminationNotFound(maximum: 17, actual: 15)) {
            try await resultsIterator.next()
        }
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func iteratorMapUpToIncludingSequenceIfNotFoundAtBoundary() async throws {
        let inputSequence = "apple orange, banana kiwi, kumquat pear, pineapple apple"
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToIncluding: ", ", throwsIfOver: 15)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple orange, ")
        #expect(try await resultsIterator.next() == "banana kiwi, ")
        #expect(try await resultsIterator.next() == "kumquat pear, ")
        await #expect(throws: AsyncSequenceReaderError.terminationNotFound(maximum: 15, actual: 15)) {
            try await resultsIterator.next()
        }
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func iteratorMapUpToIncludingSequenceIfTooLong() async throws {
        let inputSequence = "apple orange, banana kiwi, kumquat pear, pineapple apple, "
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToIncluding: ", ", throwsIfOver: 16)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple orange, ")
        #expect(try await resultsIterator.next() == "banana kiwi, ")
        #expect(try await resultsIterator.next() == "kumquat pear, ")
        await #expect(throws: AsyncSequenceReaderError.terminationNotFound(maximum: 16, actual: 17)) {
            try await resultsIterator.next()
        }
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func trapsIfUpToIncludingTerminationIsEmpty() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            var inputSequence = AnyReadableSequence("").makeAsyncIterator()
            let _ = try await inputSequence.collect(upToIncluding: "", throwsIfOver: 10)
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToElementsSequence.swift:70: Precondition failed: termination must not be empty")
        #endif
    }
    
    @Test func upToExcludingReturnsNilIfEmpty() async throws {
        var iterator = AnyReadableSequence("").makeAsyncIterator()
        #expect(try await iterator.collect(upToExcluding: " " as Character, throwsIfOver: 10) == nil)
    }
    
    @Test func iteratorMapUpToExcluding() async throws {
        let inputSequence = "apple orange banana kiwi kumquat pear pineapple "
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToExcluding: " " as Character, throwsIfOver: 10)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple")
        #expect(try await resultsIterator.next() == "orange")
        #expect(try await resultsIterator.next() == "banana")
        #expect(try await resultsIterator.next() == "kiwi")
        #expect(try await resultsIterator.next() == "kumquat")
        #expect(try await resultsIterator.next() == "pear")
        #expect(try await resultsIterator.next() == "pineapple")
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func iteratorMapUpToExcludingThrowsIfNotFound() async throws {
        let inputSequence = "apple orange banana kiwi kumquat pear pineapple"
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToExcluding: " " as Character, throwsIfOver: 10)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple")
        #expect(try await resultsIterator.next() == "orange")
        #expect(try await resultsIterator.next() == "banana")
        #expect(try await resultsIterator.next() == "kiwi")
        #expect(try await resultsIterator.next() == "kumquat")
        #expect(try await resultsIterator.next() == "pear")
        await #expect(throws: AsyncSequenceReaderError.terminationNotFound(maximum: 10, actual: 9)) {
            try await resultsIterator.next()
        }
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func iteratorMapUpToExcludingThrowsIfTooLong() async throws {
        let inputSequence = "apple orange banana kiwi kumquat pear pineapple apple pen"
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToExcluding: " " as Character, throwsIfOver: 9)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple")
        #expect(try await resultsIterator.next() == "orange")
        #expect(try await resultsIterator.next() == "banana")
        #expect(try await resultsIterator.next() == "kiwi")
        #expect(try await resultsIterator.next() == "kumquat")
        #expect(try await resultsIterator.next() == "pear")
        await #expect(throws: AsyncSequenceReaderError.terminationNotFound(maximum: 9, actual: 10)) {
            try await resultsIterator.next()
        }
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func upToExcludingSequenceReturnsNilIfEmpty() async throws {
        var iterator = AnyReadableSequence("").makeAsyncIterator()
        #expect(try await iterator.collect(upToExcluding: ", ", throwsIfOver: 10) == nil)
    }
    
    @Test func iteratorMapUpToExcludingSequence() async throws {
        let inputSequence = "apple orange, banana kiwi, kumquat pear, pineapple apple, "
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToExcluding: ", ", throwsIfOver: 17)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple orange")
        #expect(try await resultsIterator.next() == "banana kiwi")
        #expect(try await resultsIterator.next() == "kumquat pear")
        #expect(try await resultsIterator.next() == "pineapple apple")
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func iteratorMapUpToExcludingSequenceIfNotFound() async throws {
        let inputSequence = "apple orange, banana kiwi, kumquat pear, pineapple apple"
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToExcluding: ", ", throwsIfOver: 17)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple orange")
        #expect(try await resultsIterator.next() == "banana kiwi")
        #expect(try await resultsIterator.next() == "kumquat pear")
        await #expect(throws: AsyncSequenceReaderError.terminationNotFound(maximum: 17, actual: 15)) {
            try await resultsIterator.next()
        }
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func iteratorMapUpToExcludingSequenceIfNotFoundAtBoundary() async throws {
        let inputSequence = "apple orange, banana kiwi, kumquat pear, pineapple apple"
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToExcluding: ", ", throwsIfOver: 15)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple orange")
        #expect(try await resultsIterator.next() == "banana kiwi")
        #expect(try await resultsIterator.next() == "kumquat pear")
        await #expect(throws: AsyncSequenceReaderError.terminationNotFound(maximum: 15, actual: 15)) {
            try await resultsIterator.next()
        }
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func iteratorMapUpToExcludingSequenceIfTooLong() async throws {
        let inputSequence = "apple orange, banana kiwi, kumquat pear, pineapple apple, "
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            (try await iterator.collect(upToExcluding: ", ", throwsIfOver: 16)).map { String($0) }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple orange")
        #expect(try await resultsIterator.next() == "banana kiwi")
        #expect(try await resultsIterator.next() == "kumquat pear")
        await #expect(throws: AsyncSequenceReaderError.terminationNotFound(maximum: 16, actual: 17)) {
            try await resultsIterator.next()
        }
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func trapsIfUpToExcludingTerminationIsEmpty() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            var inputSequence = AnyReadableSequence("").makeAsyncIterator()
            let _ = try await inputSequence.collect(upToExcluding: "", throwsIfOver: 10)
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToElementsSequence.swift:70: Precondition failed: termination must not be empty")
        #endif
    }
    
    @Test func iteratorMapTransformingUpToIncluding() async throws {
        let inputSequence = "apple orange banana kiwi kumquat pear pineapple"
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            try await iterator.collect(upToIncluding: " " as Character) { sequence -> String in
                try await sequence.reduce(into: "") { $0.append($1) }
            }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple ")
        #expect(try await resultsIterator.next() == "orange ")
        #expect(try await resultsIterator.next() == "banana ")
        #expect(try await resultsIterator.next() == "kiwi ")
        #expect(try await resultsIterator.next() == "kumquat ")
        #expect(try await resultsIterator.next() == "pear ")
        #expect(try await resultsIterator.next() == "pineapple")
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func iteratorMapTransformingUpToIncludingSequence() async throws {
        let inputSequence = "apple, orange, banana, kiwi, kumquat, pear, pineapple"
        
        let results = inputSequence.iteratorMap { iterator -> String? in
            try await iterator.collect(upToIncluding: ", ") { sequence -> String in
                try await sequence.reduce(into: "") { $0.append($1) }
            }
        }
        
        var resultsIterator = results.makeAsyncIterator()
        
        #expect(try await resultsIterator.next() == "apple, ")
        #expect(try await resultsIterator.next() == "orange, ")
        #expect(try await resultsIterator.next() == "banana, ")
        #expect(try await resultsIterator.next() == "kiwi, ")
        #expect(try await resultsIterator.next() == "kumquat, ")
        #expect(try await resultsIterator.next() == "pear, ")
        #expect(try await resultsIterator.next() == "pineapple")
        #expect(try await resultsIterator.next() == nil)
    }
    
    @Test func trapsIfBufferedIteratorTransformingUpToIncludingTerminationIsEmpty() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            var inputSequence = AsyncBufferedIterator(AnyReadableSequence(" ").makeAsyncIterator())
            let _ = try await inputSequence.collect(upToIncluding: "") { sequence -> String in
                try await sequence.reduce(into: "") { $0.append($1) }
            }
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToElementsSequence.swift:331: Precondition failed: termination must not be empty")
        #endif
    }
    
    @Test func rawIteratorTransformingUpToIncluding() async throws {
        var iterator = AnyReadableSequence("apple orange banana kiwi kumquat pear pineapple").makeAsyncIterator()
        #expect(try await iterator.collect(upToIncluding: " " as Character) { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == "apple ")
        #expect(try await iterator.collect(upToIncluding: " " as Character) { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == "orange ")
        #expect(try await iterator.collect(upToIncluding: " " as Character) { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == "banana ")
        #expect(try await iterator.collect(upToIncluding: " " as Character) { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == "kiwi ")
        #expect(try await iterator.collect(upToIncluding: " " as Character) { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == "kumquat ")
        #expect(try await iterator.collect(upToIncluding: " " as Character) { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == "pear ")
        #expect(try await iterator.collect(upToIncluding: " " as Character) { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == "pineapple")
        #expect(try await iterator.collect(upToIncluding: " " as Character) { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == nil)
    }
    
    @Test func rawIteratorTransformingUpToIncludingSequence() async throws {
        var iterator = AnyReadableSequence("apple, orange, banana, kiwi, kumquat, pear, pineapple").makeAsyncIterator()
        #expect(try await iterator.collect(upToIncluding: ", ") { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == "apple, ")
        #expect(try await iterator.collect(upToIncluding: ", ") { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == "orange, ")
        #expect(try await iterator.collect(upToIncluding: ", ") { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == "banana, ")
        #expect(try await iterator.collect(upToIncluding: ", ") { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == "kiwi, ")
        #expect(try await iterator.collect(upToIncluding: ", ") { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == "kumquat, ")
        #expect(try await iterator.collect(upToIncluding: ", ") { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == "pear, ")
        #expect(try await iterator.collect(upToIncluding: ", ") { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == "pineapple")
        #expect(try await iterator.collect(upToIncluding: ", ") { sequence in
            try await sequence.reduce(into: "") { $0.append($1) }
        } == nil)
    }
    
    @Test func trapsIfTransformingUpToIncludingTerminationIsEmpty() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            var inputSequence = AnyReadableSequence(" ").makeAsyncIterator()
            let _ = try await inputSequence.collect(upToIncluding: "") { sequence -> String in
                try await sequence.reduce(into: "") { $0.append($1) }
            }
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToElementsSequence.swift:331: Precondition failed: termination must not be empty")
        #endif
    }
}
