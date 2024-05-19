//
//  AsyncReadUpToCountSequence.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-17.
//  Copyright © 2021-24 Mochi Development, Inc. All rights reserved.
//

#if compiler(>=5.5) && canImport(_Concurrency)

extension AsyncIteratorProtocol {
    /// Asynchronously advances by the specified number of elements, or ends the sequence if there is no next element.
    ///
    /// If a complete array could not be collected, an error is thrown and the sequence should be considered finished.
    /// - Parameter count: The number of elements to collect.
    /// - Returns: A collection with exactly `count` elements, or `nil` if the sequence is finished.
    /// - Throws: `AsyncSequenceReaderError.insufficientElements` if a complete byte sequence could not be returned by the time the sequence ended.
    public mutating func collect(_ count: Int) async throws -> [Element]? {
        assert(count >= 0, "count must be larger than 0")
        return try await collect(min: count, max: count)
    }
    
    /// Asynchronously advances by the specified minimum number of elements, continuing until the specified maximum number of elements, or ends the sequence if there is no next element.
    ///
    /// If a complete array larger than `minCount` could not be constructed, an error is thrown and the sequence should be considered finished.
    /// - Parameter minCount: The minimum number of elements to collect.
    /// - Parameter maxCount: The maximum number of elements to collect.
    /// - Returns: A collection with at least `minCount` and at most `maxCount` elements, or `nil` if the sequence is finished.
    /// - Throws: `AsyncSequenceReaderError.insufficientElements` if a complete byte sequence could not be returned by the time the sequence ended.
    public mutating func collect(min minCount: Int = 0, max maxCount: Int) async throws -> [Element]? {
        precondition(minCount <= maxCount, "maxCount must be larger than or equal to minCount")
        precondition(minCount >= 0, "minCount must be larger than 0")
        var result = [Element]()
        result.reserveCapacity(minCount)
        
        while let next = try await next() {
            result.append(next)
            
            if result.count == maxCount {
                return result
            }
        }
        
        guard !result.isEmpty else { return nil }
        
        guard result.count >= minCount else {
            throw AsyncSequenceReaderError.insufficientElements(minimum: minCount, actual: result.count)
        }
        
        return result
    }
    
    /// Collect the specified number of elements into a sequence, and transform it using the provided closure.
    ///
    /// In this example, an asynchronous sequence of Strings encodes sentences by prefixing each word sequence with a number.
    /// The number indicates how many words will be read and concatenated into a complete sentence.
    ///
    /// The closure provided to the `iteratorMap(_:)` first reads the first available string, interpreting it as a number.
    /// Then, it will collect the next `count` elements into a new sequence, transforming it into a sentence as those elements become available.
    ///
    ///     let dataStream = ... // "2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "1", "Bye!"
    ///
    ///     let sentenceStream = dataStream.iteratorMap { iterator -> String? in
    ///         guard var count = Int(try await iterator.next() ?? "") else {
    ///             throw SentenceParsing.invalidWordCount
    ///         }
    ///
    ///         return try await iterator.collect(count) { sequence -> String in
    ///             try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + $1 }
    ///         }
    ///     }
    ///
    ///     for await sentence in sentenceStream {
    ///         print("\"\(sentence)\"", terminator: ", ")
    ///     }
    ///     // Prints: "Hello, World!", "My name is Dimitri.", "", "Bye!"
    ///     
    /// - Parameter count: The number of elements the `sequenceTransform` closure will have access to.
    /// - Parameter sequenceTransform: A transformation that accepts a sequence of the specified size that can be read from, or stopped prematurely by returning early. The receiving iterator will have moved forward by the same amount of items consumed within `sequenceTransform`.
    /// - Returns: A transformed value as returned by `sequenceTransform`, or `nil` if the sequence was already finished.
    /// - Throws: `AsyncSequenceReaderError.insufficientElements` if a complete byte sequence could not be returned by the time the sequence ended.
    public mutating func collect<Transformed>(
        _ count: Int,
        sequenceTransform: (AsyncReadUpToCountSequence<Self>) async throws -> Transformed
    ) async rethrows -> Transformed? {
        assert(count >= 0, "count must be larger than 0")
        return try await collect(min: count, max: count, sequenceTransform: sequenceTransform)
    }
    
    /// Collect the minimum number of elements, continuing until the specified maximum number of elements, into a sequence, and transform it using the provided closure.
    ///
    /// In this example, an asynchronous sequence of Strings encodes sentences by prefixing each word sequence with a number.
    /// The number indicates how many words will be read and concatenated into a complete sentence.
    ///
    /// The closure provided to the `iteratorMap(_:)` first reads the first available string, interpreting it as a number.
    /// Then, it will collect the next `count` elements into a new sequence, transforming it into a sentence as those elements become available.
    ///
    ///     let dataStream = ... // "2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "2", "Bye?"
    ///
    ///     let sentenceStream = dataStream.iteratorMap { iterator -> String? in
    ///         guard var count = Int(try await iterator.next() ?? "") else {
    ///             throw SentenceParsing.invalidWordCount
    ///         }
    ///
    ///         return try await iterator.collect(min: 0, max: count) { sequence -> String in
    ///             try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + $1 }
    ///         }
    ///     }
    ///
    ///     for await sentence in sentenceStream {
    ///         print("\"\(sentence)\"", terminator: ", ")
    ///     }
    ///     // Prints: "Hello, World!", "My name is Dimitri.", "", "Bye?"
    ///
    /// - Parameter minCount: The minimum number of elements the `sequenceTransform` closure will attempt have access to. If this number cannot be guaranteed, an error will be thrown.
    /// - Parameter maxCount: The maximum number of elements the `sequenceTransform` closure will have access to.
    /// - Parameter sequenceTransform: A transformation that accepts a sequence of the specified size that can be read from, or stopped prematurely by returning early. The receiving iterator will have moved forward by the same amount of items consumed within `sequenceTransform`.
    /// - Returns: A transformed value as returned by `sequenceTransform`, or `nil` if the sequence was already finished.
    /// - Throws: `AsyncSequenceReaderError.insufficientElements` if a complete byte sequence could not be returned by the time the sequence ended.
    public mutating func collect<Transformed>(
        min minCount: Int = 0,
        max maxCount: Int,
        sequenceTransform: (AsyncReadUpToCountSequence<Self>) async throws -> Transformed
    ) async rethrows -> Transformed? {
        try await transform(with: sequenceTransform) { .init($0, minCount: minCount, maxCount: maxCount) }
    }
}

extension AsyncBufferedIterator {
    /// Collect the specified number of elements into a sequence, and transform it using the provided closure.
    ///
    /// In this example, an asynchronous sequence of Strings encodes sentences by prefixing each word sequence with a number.
    /// The number indicates how many words will be read and concatenated into a complete sentence.
    ///
    /// The closure provided to the `iteratorMap(_:)` first reads the first available string, interpreting it as a number.
    /// Then, it will collect the next `count` elements into a new sequence, transforming it into a sentence as those elements become available.
    ///
    ///     let dataStream = ... // "2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "1", "Bye!"
    ///
    ///     let sentenceStream = dataStream.iteratorMap { iterator -> String? in
    ///         guard var count = Int(try await iterator.next() ?? "") else {
    ///             throw SentenceParsing.invalidWordCount
    ///         }
    ///
    ///         return try await iterator.collect(count) { sequence -> String in
    ///             try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + $1 }
    ///         }
    ///     }
    ///
    ///     for await sentence in sentenceStream {
    ///         print("\"\(sentence)\"", terminator: ", ")
    ///     }
    ///     // Prints: "Hello, World!", "My name is Dimitri.", "", "Bye!"
    ///
    /// - Parameter count: The number of elements the `sequenceTransform` closure will have access to.
    /// - Parameter sequenceTransform: A transformation that accepts a sequence of the specified size that can be read from, or stopped prematurely by returning early. The receiving iterator will have moved forward by the same amount of items consumed within `sequenceTransform`.
    /// - Returns: A transformed value as returned by `sequenceTransform`, or `nil` if the sequence was already finished.
    /// - Throws: `AsyncSequenceReaderError.insufficientElements` if a complete byte sequence could not be returned by the time the sequence ended.
    public mutating func collect<Transformed>(
        _ count: Int,
        sequenceTransform: (AsyncReadUpToCountSequence<BaseIterator>) async throws -> Transformed
    ) async rethrows -> Transformed? {
        assert(count >= 0, "count must be larger than 0")
        return try await collect(min: count, max: count, sequenceTransform: sequenceTransform)
    }
    
    /// Collect the minimum number of elements, continuing until the specified maximum number of elements, into a sequence, and transform it using the provided closure.
    ///
    /// In this example, an asynchronous sequence of Strings encodes sentences by prefixing each word sequence with a number.
    /// The number indicates how many words will be read and concatenated into a complete sentence.
    ///
    /// The closure provided to the `iteratorMap(_:)` first reads the first available string, interpreting it as a number.
    /// Then, it will collect the next `count` elements into a new sequence, transforming it into a sentence as those elements become available.
    ///
    ///     let dataStream = ... // "2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "2", "Bye?"
    ///
    ///     let sentenceStream = dataStream.iteratorMap { iterator -> String? in
    ///         guard var count = Int(try await iterator.next() ?? "") else {
    ///             throw SentenceParsing.invalidWordCount
    ///         }
    ///
    ///         return try await iterator.collect(min: 0, max: count) { sequence -> String in
    ///             try await sequence.reduce(into: "") { $0 += ($0.isEmpty ? "" : " ") + $1 }
    ///         }
    ///     }
    ///
    ///     for await sentence in sentenceStream {
    ///         print("\"\(sentence)\"", terminator: ", ")
    ///     }
    ///     // Prints: "Hello, World!", "My name is Dimitri.", "", "Bye?"
    ///
    /// - Parameter minCount: The minimum number of elements the `sequenceTransform` closure will attempt have access to. If this number cannot be guaranteed, an error will be thrown.
    /// - Parameter maxCount: The maximum number of elements the `sequenceTransform` closure will have access to.
    /// - Parameter sequenceTransform: A transformation that accepts a sequence of the specified size that can be read from, or stopped prematurely by returning early. The receiving iterator will have moved forward by the same amount of items consumed within `sequenceTransform`.
    /// - Returns: A transformed value as returned by `sequenceTransform`, or `nil` if the sequence was already finished.
    /// - Throws: `AsyncSequenceReaderError.insufficientElements` if a complete byte sequence could not be returned by the time the sequence ended.
    public mutating func collect<Transformed>(
        min minCount: Int = 0,
        max maxCount: Int,
        sequenceTransform: (AsyncReadUpToCountSequence<BaseIterator>) async throws -> Transformed
    ) async rethrows -> Transformed? {
        try await transform(with: sequenceTransform) { .init($0, minCount: minCount, maxCount: maxCount) }
    }
}

/// An asynchronous sequence that will read from a mutable iterator so long as the specified conditions are valid.
public final class AsyncReadUpToCountSequence<BaseIterator: AsyncIteratorProtocol>: AsyncReadSequence {
    /// The baseIterator to read from.
    ///
    /// When finished with the sequence, callers should read back this value so they can continue iterating on the sequence.
    public var baseIterator: AsyncBufferedIterator<BaseIterator>
    
    @usableFromInline
    let minCount: Int
    
    @usableFromInline
    let maxCount: Int
    
    @usableFromInline
    init(
        _ baseIterator: AsyncBufferedIterator<BaseIterator>,
        minCount: Int,
        maxCount: Int
    ) {
        precondition(minCount <= maxCount, "maxCount must be larger than or equal to minCount")
        precondition(minCount >= 0, "minCount must be larger than 0")
        self.baseIterator = baseIterator
        self.minCount = minCount
        self.maxCount = maxCount
    }
}

extension AsyncReadUpToCountSequence: AsyncSequence {
    /// The type of element produced by this asynchronous sequence.
    ///
    /// The read sequence produces whatever type of element its base iterator produces.
    public typealias Element = BaseIterator.Element
    
    /// The iterator that produces elements of the read sequence.
    public struct AsyncIterator: AsyncIteratorProtocol {
        @usableFromInline
        var readSequence: AsyncReadUpToCountSequence
        
        @usableFromInline
        var numberOfElementsRead = 0
        
        @usableFromInline
        init(_ readSequence: AsyncReadUpToCountSequence) {
            self.readSequence = readSequence
        }
        
        /// Produces the next element in the sequence.
        ///
        /// This iterator checks if `numberOfElementsRead` has exceeded the max size for the sequence. If it has not, then it'll read until it does. If the next value read marks the end of the sequence, but the minimum size has not yet been reached, an error is thrown.
        @inlinable
        public mutating func next() async throws -> Element? {
            guard numberOfElementsRead < readSequence.maxCount else { return nil }
            guard let next = try await readSequence.baseIterator.next() else {
                
                guard numberOfElementsRead >= readSequence.minCount else {
                    throw AsyncSequenceReaderError.insufficientElements(minimum: readSequence.minCount, actual: numberOfElementsRead)
                }
                
                return nil
            }
            
            numberOfElementsRead += 1
            return next
        }
    }
    
    @inlinable
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(self)
    }
}

extension AsyncReadUpToCountSequence: @unchecked Sendable where BaseIterator: Sendable, BaseIterator.Element: Sendable {}
extension AsyncReadUpToCountSequence.AsyncIterator: @unchecked Sendable where BaseIterator: Sendable, BaseIterator.Element: Sendable, Element: Sendable {}

#endif
