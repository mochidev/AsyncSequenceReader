//
//  AsyncIteratorMapSequence.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-17.
//  Copyright © 2021-24 Mochi Development, Inc. All rights reserved.
//

#if compiler(>=5.5) && canImport(_Concurrency)

extension AsyncSequence {
    /// Creates an asynchronous sequence that maps the given closure over an iterator for the sequence, which can itself accept multiple reads.
    ///
    /// When finished reading from the iterator, return your completed object, and the closure will be called again with an iterator configured to continue where the first one finished.
    ///
    /// In this example, an asynchronous sequence of Strings encodes sentences by prefixing each word sequence with a number.
    /// The number indicates how many words will be read and concatenated into a complete sentence.
    ///
    /// The closure provided to the `iteratorMap(_:)` first reads the first available string, interpreting it as a number.
    /// Then, it will loop the specified number of times, accumulating those words into an array, that is finally assembled into a sentence.
    ///
    ///     let dataStream = ... // "2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "1", "Bye!"
    ///
    ///     let sentenceStream = dataStream.iteratorMap { iterator -> String? in
    ///         var count = Int(try await iterator.next() ?? "")!
    ///
    ///         var results: [String] = []
    ///
    ///         while count > 0, let next = try await iterator.next() {
    ///             results.append(next)
    ///             count -= 1
    ///         }
    ///
    ///         return results.joined(separator: " ")
    ///     }
    ///
    ///     for await sentence in sentenceStream {
    ///         print("\"\(sentence)\"", terminator: ", ")
    ///     }
    ///     // Prints: "Hello, World!", "My name is Dimitri.", "", "Bye!"
    ///
    /// - Parameter transform: A mapping closure. `transform` accepts an iterator representing the original sequence as its parameter and returns a transformed value. Returning `nil` will stop the sequence early.
    /// - Returns: An asynchronous sequence that contains, in order, elements produced by the `transform` closure.
    @inlinable
    public func iteratorMap<Transformed>(_ transform: @Sendable @escaping (_ iterator: inout AsyncBufferedIterator<AsyncIterator>) async -> Transformed) -> AsyncIteratorMapSequence<Self, Transformed> {
        AsyncIteratorMapSequence(self, transform: transform)
    }
    
    /// Creates an asynchronous sequence that maps the given closure over an iterator for the sequence, which can itself accept multiple reads.
    ///
    /// When finished reading from the iterator, return your completed object, and the closure will be called again with an iterator configured to continue where the first one finished.
    ///
    /// In this example, an asynchronous sequence of Strings encodes sentences by prefixing each word sequence with a number.
    /// The number indicates how many words will be read and concatenated into a complete sentence.
    ///
    /// The closure provided to the `iteratorMap(_:)` first reads the first available string, interpreting it as a number.
    /// Then, it will loop the specified number of times, accumulating those words into an array, that is finally assembled into a sentence.
    ///
    ///     let dataStream = ... // "2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "1", "Bye!"
    ///
    ///     let sentenceStream = dataStream.iteratorMap { iterator -> String? in
    ///         guard var count = Int(try await iterator.next() ?? "") else {
    ///             throw SentenceParsing.invalidWordCount
    ///         }
    ///
    ///         var results: [String] = []
    ///
    ///         while count > 0, let next = try await iterator.next() {
    ///             results.append(next)
    ///             count -= 1
    ///         }
    ///
    ///         guard count == 0 else {
    ///             throw SentenceParsing.missingFinalWords
    ///         }
    ///
    ///         return results.joined(separator: " ")
    ///     }
    ///
    ///     for try await sentence in sentenceStream {
    ///         print("\"\(sentence)\"", terminator: ", ")
    ///     }
    ///     // Prints: "Hello, World!", "My name is Dimitri.", "", "Bye!"
    ///
    /// - Parameter transform: A mapping closure. `transform` accepts an iterator representing the original sequence as its parameter and returns a transformed value. Returning `nil` will stop the sequence early, as will throwing an error.
    /// - Returns: An asynchronous sequence that contains, in order, elements produced by the `transform` closure.
    @inlinable
    public func iteratorMap<Transformed>(_ transform: @escaping (_ iterator: inout AsyncBufferedIterator<AsyncIterator>) async throws -> Transformed) -> AsyncThrowingIteratorMapSequence<Self, Transformed> {
        AsyncThrowingIteratorMapSequence(self, transform: transform)
    }
}

/// An asynchronous sequence that maps the given closure over the asynchronous sequence’s elements by providing it with the base sequence's iterator to assemble multiple reads into a single transformed object.
public struct AsyncIteratorMapSequence<Base: AsyncSequence, Transformed> {
    @usableFromInline
    let base: Base
    
    @usableFromInline
    let transform: @Sendable (_ iterator: inout AsyncBufferedIterator<Base.AsyncIterator>) async -> Transformed
    
    @usableFromInline
    init(
        _ base: Base,
        transform: @Sendable @escaping (_ iterator: inout AsyncBufferedIterator<Base.AsyncIterator>) async -> Transformed
    ) {
        self.base = base
        self.transform = transform
    }
}

extension AsyncIteratorMapSequence: AsyncSequence {
    /// The type of element produced by this asynchronous sequence.
    ///
    /// The map sequence produces whatever type of element its transforming closure produces.
    public typealias Element = Transformed
    
    /// The iterator that produces elements of the map sequence.
    public struct AsyncIterator: AsyncIteratorProtocol {
        @usableFromInline
        var baseIterator: AsyncBufferedIterator<Base.AsyncIterator>
        @usableFromInline
        let transform: @Sendable (_ iterator: inout AsyncBufferedIterator<Base.AsyncIterator>) async -> Transformed
        
        @usableFromInline
        init(
            _ baseIterator: AsyncBufferedIterator<Base.AsyncIterator>,
            transform: @Sendable @escaping (inout AsyncBufferedIterator<Base.AsyncIterator>) async -> Transformed
        ) {
            self.baseIterator = baseIterator
            self.transform = transform
        }
        
        /// Produces the next element in the map sequence.
        ///
        /// This iterator calls `next()` on its (wrapped) base iterator, and stores the result; if this call returns `nil`, `next()` returns `nil`. Otherwise, `next()` returns the result of calling the transforming closure on the received element.
        @inlinable
        public mutating func next() async rethrows -> Transformed? {
            guard try await baseIterator.hasMoreData() else {
                return nil
            }
            return await transform(&baseIterator)
        }
    }
    
    @inlinable
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(AsyncBufferedIterator(base.makeAsyncIterator()), transform: transform)
    }
}

public struct AsyncThrowingIteratorMapSequence<Base, Transformed> where Base : AsyncSequence {
    @usableFromInline
    let base: Base
    
    @usableFromInline
    let transform: (_ iterator: inout AsyncBufferedIterator<Base.AsyncIterator>) async throws -> Transformed
    
    @usableFromInline
    init(
        _ base: Base,
        transform: @escaping (_ iterator: inout AsyncBufferedIterator<Base.AsyncIterator>) async throws -> Transformed
    ) {
        self.base = base
        self.transform = transform
    }
}

extension AsyncThrowingIteratorMapSequence: AsyncSequence {
    public typealias Element = Transformed
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        @usableFromInline
        var baseIterator: AsyncBufferedIterator<Base.AsyncIterator>
        
        @usableFromInline
        let transform: (_ iterator: inout AsyncBufferedIterator<Base.AsyncIterator>) async throws -> Transformed
        
        @usableFromInline
        var encounteredError = false
        
        @usableFromInline
        init(_ baseIterator: AsyncBufferedIterator<Base.AsyncIterator>, transform: @escaping (inout AsyncBufferedIterator<Base.AsyncIterator>) async throws -> Transformed) {
            self.baseIterator = baseIterator
            self.transform = transform
        }
        
        /// Produces the next element in the map sequence.
        ///
        /// This iterator calls `next()` on its (wrapped) base iterator, and stores the result; if this call returns `nil`, `next()` returns `nil`. Otherwise, `next()` returns the result of calling the transforming closure on the received element. If calling the closure throws an error, the sequence ends and `next()` rethrows the error.
        @inlinable
        public mutating func next() async throws -> Transformed? {
            guard !encounteredError, try await baseIterator.hasMoreData() else {
                return nil
            }
            do {
                return try await transform(&baseIterator)
            } catch {
                encounteredError = true
                throw error
            }
        }
    }
    
    @inlinable
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(AsyncBufferedIterator(base.makeAsyncIterator()), transform: transform)
    }
}

extension AsyncIteratorMapSequence: Sendable where Base: Sendable, Transformed: Sendable, Base.Element: Sendable, Base.AsyncIterator: Sendable {}
extension AsyncIteratorMapSequence.AsyncIterator: Sendable where Base: Sendable, Base.AsyncIterator: Sendable, Transformed: Sendable, Element: Sendable, Base.Element: Sendable {}

#endif
