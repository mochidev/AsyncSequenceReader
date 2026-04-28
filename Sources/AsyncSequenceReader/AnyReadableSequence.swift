//
//  AnyReadableSequence.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2023-06-26.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

/// A type-erased convenience type to normalize synchronous and asynchronous sequences into a common async type.
public struct AnyReadableSequence<Element>: AsyncSequence {
    @usableFromInline
    let makeUnderlyingIterator: @Sendable () -> @Sendable () async throws -> Element?
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        @usableFromInline
        let makeUnderlyingNext: @Sendable () async throws -> Element?
        
        @inlinable
        init(_ makeUnderlyingNext: @Sendable @escaping () async throws -> Element?) {
            self.makeUnderlyingNext = makeUnderlyingNext
        }
        
        @inlinable
        public mutating func next() async throws -> Element? {
            try await makeUnderlyingNext()
        }
    }
    
    @inlinable
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(makeUnderlyingIterator())
    }
    
    @inlinable
    init(_ makeUnderlyingIterator: @Sendable @escaping () -> @Sendable () async throws -> Element?) {
        self.makeUnderlyingIterator = makeUnderlyingIterator
    }
    
    /// Initialize ``AnyReadableSequence`` with a sequence.
    @inlinable
    public init<S: Sequence & Sendable>(_ sequence: S) where S.Element == Element {
        self.init {
            nonisolated(unsafe) var iterator = sequence.makeIterator()
            
            return { iterator.next() }
        }
    }
    
    /// Initialize ``AnyReadableSequence`` with an async sequence.
    @inlinable
    public init<S: AsyncSequence & Sendable>(_ sequence: S) where S.Element == Element {
        self.init {
            nonisolated(unsafe) var iterator = sequence.makeAsyncIterator()
            
            return { try await iterator.next() }
        }
    }
}

extension AnyReadableSequence: Sendable where Element: Sendable {}
extension AnyReadableSequence.AsyncIterator: Sendable where Element: Sendable {}
