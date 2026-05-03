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
    
    @Test func assertsIteratorMapOnCollectNegativeCount() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let sequence = 0...10
            
            _ = try await sequence.iteratorMap { iterator -> String? in
                try await iterator.collect(-1) { sequence -> String in
                    try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
                }
            }.reduce(into: [], { $0.append($1) })
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToCountSequence.swift:232: Assertion failed: count must be larger than 0")
        #endif
    }
    
    @Test func assertsIteratorMapOnCollectNegativeMin() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let sequence = 0...10
            
            _ = try await sequence.iteratorMap { iterator -> String? in
                try await iterator.collect(min: -1, max: 0) { sequence -> String in
                    try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
                }
            }.reduce(into: [], { $0.append($1) })
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToCountSequence.swift:300: Precondition failed: minCount must be larger than or equal to 0")
        #endif
    }
    
    @Test func assertsIteratorMapOnCollectNegativeMax() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let sequence = 0...10
            
            _ = try await sequence.iteratorMap { iterator -> String? in
                try await iterator.collect(min: -1, max: -1) { sequence -> String in
                    try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
                }
            }.reduce(into: [], { $0.append($1) })
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToCountSequence.swift:300: Precondition failed: minCount must be larger than or equal to 0")
        #endif
    }
    
    @Test func assertsIteratorMapOnCollectInvertedMinMax() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let sequence = 0...10
            
            _ = try await sequence.iteratorMap { iterator -> String? in
                try await iterator.collect(min: 0, max: -1) { sequence -> String in
                    try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
                }
            }.reduce(into: [], { $0.append($1) })
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToCountSequence.swift:299: Precondition failed: maxCount must be larger than or equal to minCount")
        #endif
    }
    
    @Test func assertsRawIteratorOnTransformingCollectNegativeCount() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let sequence = 0...10
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            
            _ = try await iterator.collect(-1) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToCountSequence.swift:140: Assertion failed: count must be larger than or equal to 0")
        #endif
    }
    
    @Test func assertsRawIteratorOnCollectNegativeCount() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let sequence = 0...10
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            
            _ = try await iterator.collect(-1)
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToCountSequence.swift:18: Assertion failed: count must be larger than or equal to 0")
        #endif
    }
    
    @Test func assertsRawIteratorOnTransformingCollectZeroMin() async throws {
        #if DEBUG
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let sequence = 0...10
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            
            _ = try await iterator.collect(min: 0, max: 1) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
        }
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToCountSequence.swift:188: Assertion failed: minCount must be larger than or equal to 1, or the first value risks getting dropped")
        #endif
    }
    
    @Test func assertsRawIteratorOnTransformingCollectNegativeMin() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let sequence = 0...10
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            
            _ = try await iterator.collect(min: -1, max: 1) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToCountSequence.swift:188: Assertion failed: minCount must be larger than or equal to 1, or the first value risks getting dropped")
        #endif
    }
    
    @Test func assertsRawIteratorOnCollectNegativeMin() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let sequence = 0...10
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            
            _ = try await iterator.collect(min: -1, max: 1)
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToCountSequence.swift:31: Precondition failed: minCount must be larger than or equal to 0")
        #endif
    }
    
    @Test func assertsRawIteratorOnTransformingCollectNegativeMax() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let sequence = 0...10
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            
            _ = try await iterator.collect(min: -1, max: -1) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToCountSequence.swift:188: Assertion failed: minCount must be larger than or equal to 1, or the first value risks getting dropped")
        #endif
    }
    
    @Test func assertsRawIteratorOnCollectNegativeMax() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let sequence = 0...10
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            
            _ = try await iterator.collect(min: -1, max: -1)
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToCountSequence.swift:31: Precondition failed: minCount must be larger than or equal to 0")
        #endif
    }
    
    @Test func assertsRawIteratorOnTransformingCollectInvertedMinMax() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let sequence = 0...10
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            
            _ = try await iterator.collect(min: 0, max: -1) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToCountSequence.swift:188: Assertion failed: minCount must be larger than or equal to 1, or the first value risks getting dropped")
        #endif
    }
    
    @Test func assertsRawIteratorOnCollectInvertedMinMax() async throws {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
            let sequence = 0...10
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            
            _ = try await iterator.collect(min: 0, max: -1)
        }
        #if DEBUG
        #expect(result?.standardErrorUTF8Lines.first == "AsyncSequenceReader/AsyncReadUpToCountSequence.swift:30: Precondition failed: maxCount must be larger than or equal to minCount")
        #endif
    }
    
    @Test func iteratorMapCanCollectZero() async throws {
        let sequence = 0...10
        
        let results = sequence.iteratorMap { iterator -> String? in
            let result1 = try await iterator.collect(0) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
            #expect(result1 == "")
            
            let result2 = try await iterator.collect(min: 0, max: 0) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
            #expect(result2 == "")
            
            let result3 = try await iterator.collect(0)
            #expect(result3 == [])
            
            let result4 = try await iterator.collect(min: 0, max: 0)
            #expect(result4 == [])
            
            return try await iterator.collect(max: 11).map(String.init)
        }
        
        let allValues = try await results.reduce(into: [], { $0.append($1) })
        #expect(allValues == ["[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]"])
    }
    
    @Test func iteratorMapCanCollectOne() async throws {
        let sequence = 0...10
        
        let results = sequence.iteratorMap { iterator -> String? in
            let result1 = try await iterator.collect(1) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
            #expect(result1 == "0")
            
            let result2 = try await iterator.collect(min: 0, max: 1) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
            #expect(result2 == "1")
            
            let result3 = try await iterator.collect(min: 1, max: 1) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
            #expect(result3 == "2")
            
            let result4 = try await iterator.collect(1)
            #expect(result4 == [3])
            
            let result5 = try await iterator.collect(min: 0, max: 1)
            #expect(result5 == [4])
            
            let result6 = try await iterator.collect(min: 1, max: 1)
            #expect(result6 == [5])
            
            return try await iterator.collect(max: 5).map(String.init)
        }
        
        let allValues = try await results.reduce(into: [], { $0.append($1) })
        #expect(allValues == ["[6, 7, 8, 9, 10]"])
    }
    
    @Test func iteratorMapCanCollectAll() async throws {
        let sequence = 0...10
        
        let allValues1 = try await sequence.iteratorMap { iterator -> String? in
            try await iterator.collect(11) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
        }.reduce(into: [], { $0.append($1) })
        #expect(allValues1 == ["0 1 2 3 4 5 6 7 8 9 10"])
        
        let allValues2 = try await sequence.iteratorMap { iterator -> String? in
            try await iterator.collect(max: 12) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
        }.reduce(into: [], { $0.append($1) })
        #expect(allValues2 == ["0 1 2 3 4 5 6 7 8 9 10"])
        
        let allValues3 = try await sequence.iteratorMap { iterator in
            try await iterator.collect(max: 12)
        }.reduce(into: [], { $0.append($1) })
        #expect(allValues3 == [[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]])
    }
    
    @Test func rawIteratorCanCollectZero() async throws {
        let sequence = 0...10
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(0) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }?.reduce(into: [], { $0.append($1) })
            #expect(result == nil)
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(min: 0, max: 0) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }?.reduce(into: [], { $0.append($1) })
            #expect(result == nil)
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(0)?.reduce(into: [], { $0.append($1) })
            #expect(result == [])
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(min: 0, max: 0)?.reduce(into: [], { $0.append($1) })
            #expect(result == [])
        }
    }
    
    @Test func rawIteratorCanCollectOne() async throws {
        let sequence = 0...10
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(1) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }?.reduce(into: [], { $0.append($1) })
            #expect(result == ["0"])
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(min: 1, max: 1) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }?.reduce(into: [], { $0.append($1) })
            #expect(result == ["0"])
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(1)?.reduce(into: [], { $0.append($1) })
            #expect(result == [0])
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(min: 0, max: 1)?.reduce(into: [], { $0.append($1) })
            #expect(result == [0])
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(min: 1, max: 1)?.reduce(into: [], { $0.append($1) })
            #expect(result == [0])
        }
    }
    
    @Test func rawIteratorCanCollectAll() async throws {
        let sequence = 0...10
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(11) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
            #expect(result == "0 1 2 3 4 5 6 7 8 9 10")
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(min: 1, max: 15) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
            #expect(result == "0 1 2 3 4 5 6 7 8 9 10")
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(11)?.reduce(into: [], { $0.append($1) })
            #expect(result == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(min: 0, max: 15)?.reduce(into: [], { $0.append($1) })
            #expect(result == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(min: 11, max: 15)?.reduce(into: [], { $0.append($1) })
            #expect(result == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        }
    }
    
    @Test func rawIteratorCollectsFromInvalidCount() async throws {
        let sequence = 0...10
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            await #expect(throws: AsyncSequenceReaderError.insufficientElements(minimum: 12, actual: 11)) {
                let _ = try await iterator.collect(12) { sequence -> String in
                    try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
                }
            }
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            await #expect(throws: AsyncSequenceReaderError.insufficientElements(minimum: 12, actual: 11)) {
                let _ = try await iterator.collect(min: 12, max: 15) { sequence -> String in
                    try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
                }
            }
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            await #expect(throws: AsyncSequenceReaderError.insufficientElements(minimum: 12, actual: 11)) {
                let _ = try await iterator.collect(12)?.reduce(into: [], { $0.append($1) })
            }
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            await #expect(throws: AsyncSequenceReaderError.insufficientElements(minimum: 12, actual: 11)) {
                let _ = try await iterator.collect(min: 12, max: 15)?.reduce(into: [], { $0.append($1) })
            }
        }
    }
    
    @Test func rawIteratorCollectsFromEmptySequence() async throws {
        let sequence: [Int] = []
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(12) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
            #expect(result == nil)
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(min: 12, max: 15) { sequence -> String in
                try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + String($1) }
            }
            #expect(result == nil)
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(12)?.reduce(into: [], { $0.append($1) })
            #expect(result == nil)
        }
        
        do {
            var iterator = AnyReadableSequence(sequence).makeAsyncIterator()
            let result = try await iterator.collect(min: 12, max: 15)?.reduce(into: [], { $0.append($1) })
            #expect(result == nil)
        }
    }
}
