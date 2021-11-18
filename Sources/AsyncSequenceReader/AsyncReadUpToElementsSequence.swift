//
//  AsyncReadUpToElementsSequence.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-17.
//  Copyright © 2021 Mochi Development, Inc. All rights reserved.
//

#if compiler(>=5.5) && canImport(_Concurrency)

extension AsyncIteratorProtocol {
    
    /// Collect elements into a sequence until the termination sequence is encountered, and return them as an array, including the termination sequence.
    ///
    /// If the termination sequence was not detected before the end of the stream, or the specified maximum, an error will be thrown.
    ///
    /// In this example, an asynchronous sequence of Characters represents a list of words.
    ///
    /// The closure provided to the `iteratorMap(_:)` reads characters up to and inluding the termination provided, splitting the sequence into an array of words.
    ///
    ///     let dataStream = ... // "apple orange banana kiwi kumquat pear pineapple "
    ///
    ///     let wordStream = dataStream.iteratorMap { iterator -> String? in
    ///         (try await iterator.collect(upToIncluding: " ", throwsIfOver: 100))
    ///             .map { String($0.dropLast()) }
    ///     }
    ///
    ///     for await word in wordStream {
    ///         print("\"\(word)\"", terminator: ", ")
    ///     }
    ///     // Prints: "apple", "orange", "banana", "kiwi", "kumquat", "pear", "pineapple",
    ///
    /// - Parameter termination: The element marking the end of the sequence that will be collected.
    /// - Parameter throwsIfOver: The maximum amount of elements that will be read before an error is thrown if a termination is not detected.
    /// - Returns: An array of the collected elements, or `nil` if the sequence was already finished.
    /// - Throws: `AsyncSequenceReaderError.terminationNotFound` if a complete byte sequence could not be returned by the time the sequence ended.
    public mutating func collect(
        upToIncluding termination: Element,
        throwsIfOver maximumBufferSize: Int
    ) async throws -> [Element]? where Element: Equatable {
        try await collect(upToIncluding: [termination], throwsIfOver: maximumBufferSize)
    }
    
    /// Collect elements into a sequence until the termination sequence is encountered, and return them as an array, including the termination sequence.
    ///
    /// If the termination sequence was not detected before the end of the stream, or the specified maximum, an error will be thrown.
    ///
    /// In this example, an asynchronous sequence of Characters represents a list of words.
    ///
    /// The closure provided to the `iteratorMap(_:)` reads characters up to and inluding the termination provided, splitting the sequence into an array of words.
    ///
    ///     let dataStream = ... // "apple orange banana kiwi kumquat pear pineapple "
    ///
    ///     let wordStream = dataStream.iteratorMap { iterator -> String? in
    ///         (try await iterator.collect(upToIncluding: [" "], throwsIfOver: 100))
    ///             .map { String($0.dropLast()) }
    ///     }
    ///
    ///     for await word in wordStream {
    ///         print("\"\(word)\"", terminator: ", ")
    ///     }
    ///     // Prints: "apple", "orange", "banana", "kiwi", "kumquat", "pear", "pineapple",
    ///
    /// - Parameter termination: The sequence of elements marking the end of the sequence that will be collected.
    /// - Parameter throwsIfOver: The maximum amount of elements that will be read before an error is thrown if a termination is not detected.
    /// - Returns: An array of the collected elements, or `nil` if the sequence was already finished.
    /// - Throws: `AsyncSequenceReaderError.terminationNotFound` if a complete byte sequence could not be returned by the time the sequence ended.
    public mutating func collect(
        upToIncluding termination: [Element],
        throwsIfOver maximumBufferSize: Int
    ) async throws -> [Element]? where Element: Equatable {
        precondition(!termination.isEmpty, "stopSequence must not be empty")
        var result = [Element]()
        
        while let next = try await next() {
            if result.count == maximumBufferSize {
                throw AsyncSequenceReaderError.terminationNotFound(maximum: maximumBufferSize, actual: result.count)
            }
            
            result.append(next)
            
            if result.suffix(termination.count) == termination {
                return result
            }
        }
        
        guard !result.isEmpty else { return nil }
        
        throw AsyncSequenceReaderError.terminationNotFound(maximum: maximumBufferSize, actual: result.count)
    }
    
    /// Collect elements into a sequence until the termination sequence is encountered, and return them as an array, excluding the termination sequence.
    ///
    /// If the termination sequence was not detected before the end of the stream, or the specified maximum, an error will be thrown.
    ///
    /// In this example, an asynchronous sequence of Characters represents a list of words.
    ///
    /// The closure provided to the `iteratorMap(_:)` reads characters up to and inluding the termination provided, splitting the sequence into an array of words.
    ///
    ///     let dataStream = ... // "apple orange banana kiwi kumquat pear pineapple "
    ///
    ///     let wordStream = dataStream.iteratorMap { iterator -> String? in
    ///         (try await iterator.collect(upToExcluding: " ", throwsIfOver: 100))
    ///             .map { String($0) }
    ///     }
    ///
    ///     for await word in wordStream {
    ///         print("\"\(word)\"", terminator: ", ")
    ///     }
    ///     // Prints: "apple", "orange", "banana", "kiwi", "kumquat", "pear", "pineapple",
    ///
    /// - Parameter termination: The element marking the end of the sequence that will be collected.
    /// - Parameter throwsIfOver: The maximum amount of elements that will be read before an error is thrown if a termination is not detected.
    /// - Returns: An array of the collected elements, or `nil` if the sequence was already finished.
    /// - Throws: `AsyncSequenceReaderError.terminationNotFound` if a complete byte sequence could not be returned by the time the sequence ended.
    public mutating func collect(
        upToExcluding termination: Element,
        throwsIfOver maximumBufferSize: Int
    ) async throws -> [Element]? where Element: Equatable {
        try await collect(upToExcluding: [termination], throwsIfOver: maximumBufferSize)
    }
    
    /// Collect elements into a sequence until the termination sequence is encountered, and return them as an array, excluding the termination sequence.
    ///
    /// If the termination sequence was not detected before the end of the stream, or the specified maximum, an error will be thrown.
    ///
    /// In this example, an asynchronous sequence of Characters represents a list of words.
    ///
    /// The closure provided to the `iteratorMap(_:)` reads characters up to and inluding the termination provided, splitting the sequence into an array of words.
    ///
    ///     let dataStream = ... // "apple orange banana kiwi kumquat pear pineapple "
    ///
    ///     let wordStream = dataStream.iteratorMap { iterator -> String? in
    ///         (try await iterator.collect(upToExcluding: [" "], throwsIfOver: 100))
    ///             .map { String($0) }
    ///     }
    ///
    ///     for await word in wordStream {
    ///         print("\"\(word)\"", terminator: ", ")
    ///     }
    ///     // Prints: "apple", "orange", "banana", "kiwi", "kumquat", "pear", "pineapple",
    ///
    /// - Parameter termination: The sequence of elements marking the end of the sequence that will be collected.
    /// - Parameter throwsIfOver: The maximum amount of elements that will be read before an error is thrown if a termination is not detected.
    /// - Returns: An array of the collected elements, or `nil` if the sequence was already finished.
    /// - Throws: `AsyncSequenceReaderError.terminationNotFound` if a complete byte sequence could not be returned by the time the sequence ended.
    public mutating func collect(
        upToExcluding termination: [Element],
        throwsIfOver maximumBufferSize: Int
    ) async throws -> [Element]? where Element: Equatable {
        try await collect(upToIncluding: termination, throwsIfOver: maximumBufferSize)?.dropLast(termination.count)
    }
    
    /// Collect elements into a sequence until the termination sequence is encountered, and transform it using the provided closure.
    ///
    /// - Note: It is up to the caller to verify if the termination sequence was encountered or not, which can easily be done by checking `result.suffix(termination.count) == termination`.
    ///
    /// In this example, an asynchronous sequence of Characters represents a list of words.
    ///
    /// The closure provided to the `iteratorMap(_:)` reads characters up to and inluding the termination provided, splitting the sequence into an array of words.
    ///
    ///     let dataStream = ... // "apple orange banana kiwi kumquat pear pineapple"
    ///
    ///     let wordStream = dataStream.iteratorMap { iterator -> String? in
    ///         let word = await iterator.collect(upToIncluding: " ") { sequence -> String in
    ///             await sequence.reduce(into: "") { $0.append($1) }
    ///         }
    ///
    ///         if let word = word, word.hasSuffix(" ") {
    ///             return String(word.dropLast(1))
    ///         }
    ///
    ///         return word
    ///     }
    ///
    ///     for await word in wordStream {
    ///         print("\"\(word)\"", terminator: ", ")
    ///     }
    ///     // Prints: "apple", "orange", "banana", "kiwi", "kumquat", "pear", "pineapple",
    ///
    /// - Parameter termination: The element marking the end of the sequence the `sequenceTransform` closure will have access to.
    /// - Parameter sequenceTransform: A transformation that accepts a sequence containing elements up to the termination that can be read from, or stopped prematurely by returning early. The receiving iterator will have moved forward by the same amount of items consumed within `sequenceTransform`.
    /// - Returns: A transformed value as returned by `sequenceTransform`, or `nil` if the sequence was already finished.
    public mutating func collect<Transformed>(
        upToIncluding termination: Element,
        sequenceTransform: (AsyncReadUpToElementsSequence<Self>) async -> Transformed
    ) async -> Transformed? where Element: Equatable {
        await collect(upToIncluding: [termination], sequenceTransform: sequenceTransform)
    }
    
    /// Collect elements into a sequence until the termination sequence is encountered, and transform it using the provided closure.
    ///
    /// - Note: It is up to the caller to verify if the termination sequence was encountered or not, which can easily be done by checking `result.suffix(termination.count) == termination`.
    ///
    /// In this example, an asynchronous sequence of Characters represents a list of words.
    ///
    /// The closure provided to the `iteratorMap(_:)` reads characters up to and inluding the termination provided, splitting the sequence into an array of words.
    ///
    ///     let dataStream = ... // "apple orange banana kiwi kumquat pear pineapple"
    ///
    ///     let wordStream = dataStream.iteratorMap { iterator -> String? in
    ///         let word = await iterator.collect(upToIncluding: [" "]) { sequence -> String in
    ///             await sequence.reduce(into: "") { $0.append($1) }
    ///         }
    ///
    ///         if let word = word, word.hasSuffix(" ") {
    ///             return String(word.dropLast(1))
    ///         }
    ///
    ///         return word
    ///     }
    ///
    ///     for await word in wordStream {
    ///         print("\"\(word)\"", terminator: ", ")
    ///     }
    ///     // Prints: "apple", "orange", "banana", "kiwi", "kumquat", "pear", "pineapple",
    ///
    /// - Parameter termination: The sequence of elements marking the end of the sequence the `sequenceTransform` closure will have access to.
    /// - Parameter sequenceTransform: A transformation that accepts a sequence containing elements up to the termination that can be read from, or stopped prematurely by returning early. The receiving iterator will have moved forward by the same amount of items consumed within `sequenceTransform`.
    /// - Returns: A transformed value as returned by `sequenceTransform`, or `nil` if the sequence was already finished.
    public mutating func collect<Transformed>(
        upToIncluding termination: [Element],
        sequenceTransform: (AsyncReadUpToElementsSequence<Self>) async -> Transformed
    ) async -> Transformed? where Element: Equatable {
        await transform(with: sequenceTransform) { .init($0, termination: termination) }
    }
    
    /// Collect elements into a sequence until the termination sequence is encountered, and transform it using the provided closure.
    ///
    /// - Note: It is up to the caller to verify if the termination sequence was encountered or not, which can easily be done by checking `result.suffix(termination.count) == termination`.
    ///
    /// In this example, an asynchronous sequence of Characters represents a list of words.
    ///
    /// The closure provided to the `iteratorMap(_:)` reads characters up to and inluding the termination provided, splitting the sequence into an array of words.
    ///
    ///     let dataStream = ... // "apple orange banana kiwi kumquat pear pineapple"
    ///
    ///     let wordStream = dataStream.iteratorMap { iterator -> String? in
    ///         let word = await iterator.collect(upToIncluding: " ") { sequence -> String in
    ///             await sequence.reduce(into: "") { $0.append($1) }
    ///         }
    ///
    ///         if let word = word, word.hasSuffix(" ") {
    ///             return String(word.dropLast(1))
    ///         }
    ///
    ///         return word
    ///     }
    ///
    ///     for await word in wordStream {
    ///         print("\"\(word)\"", terminator: ", ")
    ///     }
    ///     // Prints: "apple", "orange", "banana", "kiwi", "kumquat", "pear", "pineapple",
    ///
    /// - Parameter termination: The element marking the end of the sequence the `sequenceTransform` closure will have access to.
    /// - Parameter sequenceTransform: A transformation that accepts a sequence containing elements up to the termination that can be read from, or stopped prematurely by returning early. The receiving iterator will have moved forward by the same amount of items consumed within `sequenceTransform`.
    /// - Returns: A transformed value as returned by `sequenceTransform`, or `nil` if the sequence was already finished.
    public mutating func collect<Transformed>(
        upToIncluding termination: Element,
        sequenceTransform: (AsyncReadUpToElementsSequence<Self>) async throws -> Transformed
    ) async rethrows -> Transformed? where Element: Equatable {
        try await collect(upToIncluding: [termination], sequenceTransform: sequenceTransform)
    }
    
    /// Collect elements into a sequence until the termination sequence is encountered, and transform it using the provided closure.
    ///
    /// - Note: It is up to the caller to verify if the termination sequence was encountered or not, which can easily be done by checking `result.suffix(termination.count) == termination`.
    ///
    /// In this example, an asynchronous sequence of Characters represents a list of words.
    ///
    /// The closure provided to the `iteratorMap(_:)` reads characters up to and inluding the termination provided, splitting the sequence into an array of words.
    ///
    ///     let dataStream = ... // "apple orange banana kiwi kumquat pear pineapple"
    ///
    ///     let wordStream = dataStream.iteratorMap { iterator -> String? in
    ///         let word = await iterator.collect(upToIncluding: [" "]) { sequence -> String in
    ///             await sequence.reduce(into: "") { $0.append($1) }
    ///         }
    ///
    ///         if let word = word, word.hasSuffix(" ") {
    ///             return String(word.dropLast(1))
    ///         }
    ///
    ///         return word
    ///     }
    ///
    ///     for await word in wordStream {
    ///         print("\"\(word)\"", terminator: ", ")
    ///     }
    ///     // Prints: "apple", "orange", "banana", "kiwi", "kumquat", "pear", "pineapple",
    ///
    /// - Parameter termination: The sequence of elements marking the end of the sequence the `sequenceTransform` closure will have access to.
    /// - Parameter sequenceTransform: A transformation that accepts a sequence containing elements up to the termination that can be read from, or stopped prematurely by returning early. The receiving iterator will have moved forward by the same amount of items consumed within `sequenceTransform`.
    /// - Returns: A transformed value as returned by `sequenceTransform`, or `nil` if the sequence was already finished.
    public mutating func collect<Transformed>(
        upToIncluding termination: [Element],
        sequenceTransform: (AsyncReadUpToElementsSequence<Self>) async throws -> Transformed
    ) async rethrows -> Transformed? where Element: Equatable {
        try await transform(with: sequenceTransform) { .init($0, termination: termination) }
    }
}

extension AsyncBufferedIterator {
    
    /// Collect elements into a sequence until the termination sequence is encountered, and transform it using the provided closure.
    ///
    /// - Note: It is up to the caller to verify if the termination sequence was encountered or not, which can easily be done by checking `result.suffix(termination.count) == termination`.
    ///
    /// In this example, an asynchronous sequence of Characters represents a list of words.
    ///
    /// The closure provided to the `iteratorMap(_:)` reads characters up to and inluding the termination provided, splitting the sequence into an array of words.
    ///
    ///     let dataStream = ... // "apple orange banana kiwi kumquat pear pineapple"
    ///
    ///     let wordStream = dataStream.iteratorMap { iterator -> String? in
    ///         let word = await iterator.collect(upToIncluding: " ") { sequence -> String in
    ///             await sequence.reduce(into: "") { $0.append($1) }
    ///         }
    ///
    ///         if let word = word, word.hasSuffix(" ") {
    ///             return String(word.dropLast(1))
    ///         }
    ///
    ///         return word
    ///     }
    ///
    ///     for await word in wordStream {
    ///         print("\"\(word)\"", terminator: ", ")
    ///     }
    ///     // Prints: "apple", "orange", "banana", "kiwi", "kumquat", "pear", "pineapple",
    ///
    /// - Parameter termination: The element marking the end of the sequence the `sequenceTransform` closure will have access to.
    /// - Parameter sequenceTransform: A transformation that accepts a sequence containing elements up to the termination that can be read from, or stopped prematurely by returning early. The receiving iterator will have moved forward by the same amount of items consumed within `sequenceTransform`.
    /// - Returns: A transformed value as returned by `sequenceTransform`, or `nil` if the sequence was already finished.
    public mutating func collect<Transformed>(
        upToIncluding termination: Element,
        sequenceTransform: (AsyncReadUpToElementsSequence<Self>) async -> Transformed
    ) async -> Transformed? where Element: Equatable {
        await collect(upToIncluding: [termination], sequenceTransform: sequenceTransform)
    }
    
    /// Collect elements into a sequence until the termination sequence is encountered, and transform it using the provided closure.
    ///
    /// - Note: It is up to the caller to verify if the termination sequence was encountered or not, which can easily be done by checking `result.suffix(termination.count) == termination`.
    ///
    /// In this example, an asynchronous sequence of Characters represents a list of words.
    ///
    /// The closure provided to the `iteratorMap(_:)` reads characters up to and inluding the termination provided, splitting the sequence into an array of words.
    ///
    ///     let dataStream = ... // "apple orange banana kiwi kumquat pear pineapple"
    ///
    ///     let wordStream = dataStream.iteratorMap { iterator -> String? in
    ///         let word = await iterator.collect(upToIncluding: [" "]) { sequence -> String in
    ///             await sequence.reduce(into: "") { $0.append($1) }
    ///         }
    ///
    ///         if let word = word, word.hasSuffix(" ") {
    ///             return String(word.dropLast(1))
    ///         }
    ///
    ///         return word
    ///     }
    ///
    ///     for await word in wordStream {
    ///         print("\"\(word)\"", terminator: ", ")
    ///     }
    ///     // Prints: "apple", "orange", "banana", "kiwi", "kumquat", "pear", "pineapple",
    ///
    /// - Parameter termination: The sequence of elements marking the end of the sequence the `sequenceTransform` closure will have access to.
    /// - Parameter sequenceTransform: A transformation that accepts a sequence containing elements up to the termination that can be read from, or stopped prematurely by returning early. The receiving iterator will have moved forward by the same amount of items consumed within `sequenceTransform`.
    /// - Returns: A transformed value as returned by `sequenceTransform`, or `nil` if the sequence was already finished.
    public mutating func collect<Transformed>(
        upToIncluding termination: [Element],
        sequenceTransform: (AsyncReadUpToElementsSequence<BaseIterator>) async -> Transformed
    ) async -> Transformed? where Element: Equatable {
        await transform(with: sequenceTransform) { .init($0, termination: termination) }
    }
    
    /// Collect elements into a sequence until the termination sequence is encountered, and transform it using the provided closure.
    ///
    /// - Note: It is up to the caller to verify if the termination sequence was encountered or not, which can easily be done by checking `result.suffix(termination.count) == termination`.
    ///
    /// In this example, an asynchronous sequence of Characters represents a list of words.
    ///
    /// The closure provided to the `iteratorMap(_:)` reads characters up to and inluding the termination provided, splitting the sequence into an array of words.
    ///
    ///     let dataStream = ... // "apple orange banana kiwi kumquat pear pineapple"
    ///
    ///     let wordStream = dataStream.iteratorMap { iterator -> String? in
    ///         let word = await iterator.collect(upToIncluding: " ") { sequence -> String in
    ///             await sequence.reduce(into: "") { $0.append($1) }
    ///         }
    ///
    ///         if let word = word, word.hasSuffix(" ") {
    ///             return String(word.dropLast(1))
    ///         }
    ///
    ///         return word
    ///     }
    ///
    ///     for await word in wordStream {
    ///         print("\"\(word)\"", terminator: ", ")
    ///     }
    ///     // Prints: "apple", "orange", "banana", "kiwi", "kumquat", "pear", "pineapple",
    ///
    /// - Parameter termination: The element marking the end of the sequence the `sequenceTransform` closure will have access to.
    /// - Parameter sequenceTransform: A transformation that accepts a sequence containing elements up to the termination that can be read from, or stopped prematurely by returning early. The receiving iterator will have moved forward by the same amount of items consumed within `sequenceTransform`.
    /// - Returns: A transformed value as returned by `sequenceTransform`, or `nil` if the sequence was already finished.
    public mutating func collect<Transformed>(
        upToIncluding termination: Element,
        sequenceTransform: (AsyncReadUpToElementsSequence<Self>) async throws -> Transformed
    ) async rethrows -> Transformed? where Element: Equatable {
        try await collect(upToIncluding: [termination], sequenceTransform: sequenceTransform)
    }
    
    /// Collect elements into a sequence until the termination sequence is encountered, and transform it using the provided closure.
    ///
    /// - Note: It is up to the caller to verify if the termination sequence was encountered or not, which can easily be done by checking `result.suffix(termination.count) == termination`.
    ///
    /// In this example, an asynchronous sequence of Characters represents a list of words.
    ///
    /// The closure provided to the `iteratorMap(_:)` reads characters up to and inluding the termination provided, splitting the sequence into an array of words.
    ///
    ///     let dataStream = ... // "apple orange banana kiwi kumquat pear pineapple"
    ///
    ///     let wordStream = dataStream.iteratorMap { iterator -> String? in
    ///         let word = await iterator.collect(upToIncluding: [" "]) { sequence -> String in
    ///             await sequence.reduce(into: "") { $0.append($1) }
    ///         }
    ///
    ///         if let word = word, word.hasSuffix(" ") {
    ///             return String(word.dropLast(1))
    ///         }
    ///
    ///         return word
    ///     }
    ///
    ///     for await word in wordStream {
    ///         print("\"\(word)\"", terminator: ", ")
    ///     }
    ///     // Prints: "apple", "orange", "banana", "kiwi", "kumquat", "pear", "pineapple",
    ///
    /// - Parameter termination: The sequence of elements marking the end of the sequence the `sequenceTransform` closure will have access to.
    /// - Parameter sequenceTransform: A transformation that accepts a sequence containing elements up to the termination that can be read from, or stopped prematurely by returning early. The receiving iterator will have moved forward by the same amount of items consumed within `sequenceTransform`.
    /// - Returns: A transformed value as returned by `sequenceTransform`, or `nil` if the sequence was already finished.
    public mutating func collect<Transformed>(
        upToIncluding termination: [Element],
        sequenceTransform: (AsyncReadUpToElementsSequence<BaseIterator>) async throws -> Transformed
    ) async rethrows -> Transformed? where Element: Equatable {
        try await transform(with: sequenceTransform) { .init($0, termination: termination) }
    }
}

/// An asynchronous sequence that will read from a mutable iterator so long as the specified conditions are valid.
public class AsyncReadUpToElementsSequence<BaseIterator: AsyncIteratorProtocol>: AsyncReadSequence where BaseIterator.Element: Equatable {
    /// The baseIterator to read from.
    ///
    /// When finished with the sequence, callers should read back this value so they can continue iterating on the sequence.
    public var baseIterator: AsyncBufferedIterator<BaseIterator>
    
    @usableFromInline
    let termination: [Element]
    
    @usableFromInline
    init(
        _ baseIterator: AsyncBufferedIterator<BaseIterator>,
        termination: [Element]
    ) {
        precondition(!termination.isEmpty, "termination must not be empty")
        self.baseIterator = baseIterator
        self.termination = termination
    }
}

extension AsyncReadUpToElementsSequence: AsyncSequence {
    /// The type of element produced by this asynchronous sequence.
    ///
    /// The read sequence produces whatever type of element its base iterator produces.
    public typealias Element = BaseIterator.Element
    
    /// The iterator that produces elements of the read sequence.
    public struct AsyncIterator: AsyncIteratorProtocol {
        @usableFromInline
        var readSequence: AsyncReadUpToElementsSequence
        
        @usableFromInline
        var bufferedSuffix: [Element] = []
        
        @usableFromInline
        init(_ readSequence: AsyncReadUpToElementsSequence) {
            self.readSequence = readSequence
            bufferedSuffix.reserveCapacity(readSequence.termination.count)
        }
        
        /// Produces the next element in the sequence.
        ///
        /// This iterator checks if `bufferedSuffix` has is equal to the termination. If it isn't, then it'll read until it does. If the next value read marks the end of the sequence, but the termination was not identified, the sequence ends without error.
        @inlinable
        public mutating func next() async rethrows -> Element? {
            guard
                bufferedSuffix != readSequence.termination,
                let next = try await readSequence.baseIterator.next()
            else { return nil }
            
            if bufferedSuffix.count == readSequence.termination.count { bufferedSuffix.removeFirst() }
            bufferedSuffix.append(next)
            return next
        }
    }
    
    @inlinable
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(self)
    }
}
#endif
