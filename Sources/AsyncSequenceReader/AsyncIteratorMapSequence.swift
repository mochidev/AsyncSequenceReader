//
//  AsyncIteratorMapSequence.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-17.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

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
    /// - Note: This overload covers when the transformation throws a different (or no) error than the underlying sequence.
    /// - Parameter transform: A mapping closure. `transform` accepts an iterator representing the original sequence as its parameter and returns a transformed value. Returning `nil` will stop the sequence early, as will throwing an error.
    /// - Returns: An asynchronous sequence that contains, in order, elements produced by the `transform` closure.
    @inlinable
    @_disfavoredOverload
    public func iteratorMap<Transformed, TransformFailure: Error>(
        _ transform: sending @escaping (_ iterator: inout AsyncBufferedIterator<AsyncIterator>) async throws(TransformFailure) -> Transformed
    ) -> AsyncIteratorMapSequence<Self, Transformed, TransformFailure> {
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
    /// - Note: This overload covers when the transformation throws the same (or no) error than the underlying sequence, but can only be verified on newer distributions of Swift.
    /// - Parameter transform: A mapping closure. `transform` accepts an iterator representing the original sequence as its parameter and returns a transformed value. Returning `nil` will stop the sequence early, as will throwing an error.
    /// - Returns: An asynchronous sequence that contains, in order, elements produced by the `transform` closure.
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @inlinable
    public func iteratorMap<Transformed>(
        _ transform: sending @escaping (_ iterator: inout AsyncBufferedIterator<AsyncIterator>) async throws(Failure) -> Transformed
    ) -> AsyncIteratorMapSequence<Self, Transformed, Failure> {
        AsyncIteratorMapSequence(self, transform: transform)
    }
}

extension Sequence where Self: Sendable {
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
    ///     let dataStream = ["2", "Hello,", "World!", "4", "My", "name", "is", "Dimitri.", "0", "1", "Bye!"]
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
    /// - Parameter transform: A mapping closure. `transform` accepts an iterator representing the original sequence as its parameter and returns a transformed value. Returning `nil` will stop the sequence early, as will throwing an error.
    /// - Returns: An asynchronous sequence that contains, in order, elements produced by the `transform` closure.
    @inlinable
    public func iteratorMap<Transformed, TransformFailure: Error>(
        _ transform: sending @escaping (_ iterator: inout AsyncBufferedIterator<AnyReadableSequence<Element, Never>.AsyncIterator>) async throws(TransformFailure) -> Transformed
    ) -> AsyncIteratorMapSequence<AnyReadableSequence<Element, Never>, Transformed, TransformFailure> {
        AsyncIteratorMapSequence(AnyReadableSequence(self), transform: transform)
    }
}

/// An asynchronous sequence that maps the given closure over the asynchronous sequence’s elements by providing it with the base sequence's iterator to assemble multiple reads into a single transformed object.
public struct AsyncIteratorMapSequence<Base: AsyncSequence, Transformed, TransformFailure: Error> {
    @usableFromInline
    let base: Base
    
    @usableFromInline
    nonisolated(unsafe) let transform: (_ iterator: inout AsyncBufferedIterator<Base.AsyncIterator>) async throws(TransformFailure) -> Transformed
    
    @usableFromInline
    init(
        _ base: Base,
        transform: @escaping (_ iterator: inout AsyncBufferedIterator<Base.AsyncIterator>) async throws(TransformFailure) -> Transformed
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
        nonisolated(unsafe) let transform: (_ iterator: inout AsyncBufferedIterator<Base.AsyncIterator>) async throws(TransformFailure) -> Transformed
        
        @usableFromInline
        var encounteredError = false
        
        @usableFromInline
        init(
            _ baseIterator: AsyncBufferedIterator<Base.AsyncIterator>,
            transform: @escaping (inout AsyncBufferedIterator<Base.AsyncIterator>) async throws(TransformFailure) -> Transformed
        ) {
            self.baseIterator = baseIterator
            self.transform = transform
        }
        
        /// Produces the next element in the map sequence.
        ///
        /// This iterator calls `next()` on its (wrapped) base iterator, and stores the result; if this call returns `nil`, `next()` returns `nil`. Otherwise, `next()` returns the result of calling the transforming closure on the received element. If calling the transformation throws an error, the sequence ends and `next()` rethrows the error.
        @inlinable
        @_disfavoredOverload
        public mutating func next() async throws -> Transformed? {
            try await next()
        }
        
        /// Produces the next element in the map sequence.
        ///
        /// This iterator calls `next()` on its (wrapped) base iterator, and stores the result; if this call returns `nil`, `next()` returns `nil`. Otherwise, `next()` returns the result of calling the transforming closure on the received element. If calling the transformation throws an error, the sequence ends and `next()` rethrows the error.
        @inlinable
        public mutating func next(isolation actor: isolated (any Actor)? = #isolation) async throws -> Transformed? {
            guard !encounteredError, await baseIterator.hasMoreData(isolation: actor) else {
                return nil
            }
            do {
                #if compiler(>=6.2)
                return try await transform(&baseIterator)
                #else
                /// Swift 6.0 and Swift 6.1 require a bypass for `non-sendable type 'Transformed' returned by implicitly asynchronous call to nonisolated function cannot cross actor boundary`
                nonisolated(unsafe) var iterator = self
                defer { self = iterator }
                let value = try await iterator._transformSendable()
                return value as! Transformed?
                #endif
            } catch {
                encounteredError = true
                throw error
            }
        }
        
        /// Produces the next element in the map sequence.
        ///
        /// This iterator calls `next()` on its (wrapped) base iterator, and stores the result; if this call returns `nil`, `next()` returns `nil`. Otherwise, `next()` returns the result of calling the transforming closure on the received element.
        @inlinable
        public mutating func next(isolation actor: isolated (any Actor)? = #isolation) async rethrows -> Transformed? where TransformFailure == Never {
            guard await baseIterator.hasMoreData(isolation: actor) else {
                return nil
            }
            #if compiler(>=6.2)
            return await transform(&baseIterator)
            #else
            /// Swift 6.0 and Swift 6.1 require a bypass for `non-sendable type 'Transformed' returned by implicitly asynchronous call to nonisolated function cannot cross actor boundary`
            nonisolated(unsafe) var iterator = self
            defer { self = iterator }
            let value = await iterator._transformSendable()
            return value as! Transformed?
            #endif
        }
        
        #if compiler(<6.2)
        /// Swift 6.0 and Swift 6.1 require a bypass for `non-sendable type 'Transformed' returned by implicitly asynchronous call to nonisolated function cannot cross actor boundary`
        @usableFromInline
        mutating func _transformSendable() async throws(TransformFailure) -> sending Any {
            try await transform(&baseIterator) as Any
        }
        #endif
    }
    
    @inlinable
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(AsyncBufferedIterator(base.makeAsyncIterator()), transform: transform)
    }
}

extension AsyncIteratorMapSequence: Sendable where Base: Sendable, Transformed: Sendable, Base.Element: Sendable, Base.AsyncIterator: Sendable {}
extension AsyncIteratorMapSequence.AsyncIterator: Sendable where Base: Sendable, Base.AsyncIterator: Sendable, Transformed: Sendable, Element: Sendable, Base.Element: Sendable {}
