//
//  AnyReadableSequence.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2023-06-26.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

/// A type-erased convenience type to normalize synchronous and asynchronous sequences into a common async type.
///
/// - Note: `AnyReadableSequence` supports being iterated multiple times _only_ if the underlying sequence supports being iterated multiple times.
public struct AnyReadableSequence<Element, Failure: Error>: AsyncSequence {
    @usableFromInline
    let makeUnderlyingIterator: @Sendable () -> @Sendable () async throws(Failure) -> Element?
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        @usableFromInline
        let makeUnderlyingNext: @Sendable () async throws(Failure) -> Element?
        
        @inlinable
        init(_ makeUnderlyingNext: @Sendable @escaping () async throws(Failure) -> Element?) {
            self.makeUnderlyingNext = makeUnderlyingNext
        }
        
        @inlinable
        public mutating func next() async throws(Failure) -> Element? {
            try await makeUnderlyingNext()
        }
    }
    
    @inlinable
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(makeUnderlyingIterator())
    }
    
    @inlinable
    init(_ makeUnderlyingIterator: @Sendable @escaping () -> @Sendable () async throws(Failure) -> Element?) {
        self.makeUnderlyingIterator = makeUnderlyingIterator
    }
    
    /// Initialize ``AnyReadableSequence`` with a sequence.
    @inlinable
    @_disfavoredOverload
    public init<S: Sequence & Sendable>(_ sequence: S) where S.Element == Element, Failure == Never {
        self.init {
            nonisolated(unsafe) var iterator = sequence.makeIterator()
            
            return { iterator.next() }
        }
    }
    
    /// Initialize ``AnyReadableSequence`` with an async sequence.
    @inlinable
    public init<S: AsyncSequence & Sendable>(_ sequence: S) where S.Element == Element, Failure == any Error {
        self.init {
            nonisolated(unsafe) var iterator = sequence.makeAsyncIterator()
            
            return { try await iterator.next() }
        }
    }
    
    /// Initialize ``AnyReadableSequence`` with an async sequence.
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @inlinable
    public init<S: AsyncSequence & Sendable>(_ sequence: S) where S.Element == Element, S.Failure == Failure {
        self.init {
            nonisolated(unsafe) var iterator = sequence.makeAsyncIterator()
            
            return { () throws(Failure) -> Element? in
                try await iterator.next(isolation: #isolation)
            }
        }
    }
}

extension AnyReadableSequence: Sendable where Element: Sendable {}
extension AnyReadableSequence.AsyncIterator: Sendable where Element: Sendable {}
